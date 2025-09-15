//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

/// A wrapper around ``BackupExportJob`` that prevents overlapping job runs and
/// tracks progress updates for the currently-running job.
public protocol BackupExportJobRunner {

    /// An `AsyncStream` that yields updates on the progress of Backup exports.
    ///
    /// An update will be yielded once with the current progress, and again any
    /// time the current progress is updated. A `nil` progress value indicates
    /// that no export job is running.
    func updates() -> AsyncStream<OWSSequentialProgress<BackupExportJobStep>?>

    /// Cooperatively cancel the running export job, if one exists.
    func cancelIfRunning()

    /// Run ``BackupExportJob``.
    ///
    /// - Important
    /// Only one export job is allowed to run at once, so calls to this method
    /// may either start new async work or return the result of awaiting
    /// existing work. Consequently, this method is not directly cooperatively
    /// cancellable.
    ///
    /// Instead, callers who wish to cancel a running job must use
    /// ``cancelIfRunning()``, which will cancel the running export job for all
    /// callers waiting on it.
    ///
    /// - SeeAlso ``BackupExportJob/exportAndUploadBackup(onProgressUpdate:)``
    func run() async throws(BackupExportJobError)
}

class BackupExportJobRunnerImpl: BackupExportJobRunner {
    private struct State {
        struct ProgressObserver {
            let id = UUID()
            let block: (OWSSequentialProgress<BackupExportJobStep>?) -> Void
        }

        var currentExportJobTask: Task<Result<Void, BackupExportJobError>, Never>?
        var latestProgress: OWSSequentialProgress<BackupExportJobStep>? {
            didSet {
                for observer in progressObservers {
                    observer.block(latestProgress)
                }
            }
        }
        var progressObservers: [ProgressObserver] = []
    }

    private let backupExportJob: BackupExportJob
    private let state: SeriallyAccessedState<State>

    init(backupExportJob: BackupExportJob) {
        self.backupExportJob = backupExportJob
        self.state = SeriallyAccessedState(State())
    }

    // MARK: -

    func updates() -> AsyncStream<OWSSequentialProgress<BackupExportJobStep>?> {
        return AsyncStream { continuation in
            let observer = addProgressObserver { exportJobProgress in
                continuation.yield(exportJobProgress)
            }

            continuation.onTermination = { [weak self] reason in
                guard let self else { return }
                removeProgressObserver(observer)
            }
        }
    }

    private func addProgressObserver(
        block: @escaping (OWSSequentialProgress<BackupExportJobStep>?) -> Void
    ) -> State.ProgressObserver {
        let observer = State.ProgressObserver(block: block)

        state.enqueueUpdate { _state in
            observer.block(_state.latestProgress)
            _state.progressObservers.append(observer)
        }

        return observer
    }

    private func removeProgressObserver(_ observer: State.ProgressObserver) {
        state.enqueueUpdate { _state in
            _state.progressObservers.removeAll { $0.id == observer.id }
        }
    }

    // MARK: -

    func cancelIfRunning() {
        state.enqueueUpdate { _state in
            if let currentExportJobTask = _state.currentExportJobTask {
                currentExportJobTask.cancel()
            }
        }
    }

    // MARK: -

    func run() async throws(BackupExportJobError) {
        let exportJobTask: Task<Result<Void, BackupExportJobError>, Never>
        do throws(CancellationError) {
            exportJobTask = try await getOrStartExportJobTask()
        } catch {
            throw .cancellationError
        }

        try await exportJobTask.value.get()
    }

    private func getOrStartExportJobTask() async throws(CancellationError) -> Task<Result<Void, BackupExportJobError>, Never> {
        try await state.awaitUpdate { [self] _state in
            if let currentExportJobTask = _state.currentExportJobTask {
                return currentExportJobTask
            }

            let newExportJobTask = Task { () async -> Result<Void, BackupExportJobError> in
                defer {
                    exportJobDidComplete()
                }

                do throws(BackupExportJobError) {
                    try await backupExportJob.exportAndUploadBackup(
                        mode: .manual(OWSSequentialProgress<BackupExportJobStep>
                            .createSink { [weak self] exportJobProgress in
                                self?.exportJobDidUpdateProgress(exportJobProgress)
                            }
                        )
                    )
                    return .success(())
                } catch {
                    return .failure(error)
                }
            }

            _state.currentExportJobTask = newExportJobTask
            return newExportJobTask
        }
    }

    private func exportJobDidUpdateProgress(_ exportJobProgress: OWSSequentialProgress<BackupExportJobStep>) {
        self.state.enqueueUpdate { _state in
            _state.latestProgress = exportJobProgress
        }
    }

    private func exportJobDidComplete() {
        self.state.enqueueUpdate { _state in
            _state.currentExportJobTask = nil
            _state.latestProgress = nil
        }
    }
}
