//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

// The block is executed immediately if called from the
// main thread; otherwise it is dispatched async to the
// main thread.
public func DispatchMainThreadSafe(_ block: @escaping @MainActor () -> Void) {
    if Thread.isMainThread {
        MainActor.assumeIsolated(block)
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

// The block is executed immediately if called from the
// main thread; otherwise it is dispatched sync to the
// main thread.
public func DispatchSyncMainThreadSafe(_ block: @escaping @MainActor () -> Void) {
    if Thread.isMainThread {
        MainActor.assumeIsolated(block)
    } else {
        DispatchQueue.main.sync(execute: block)
    }
}

@objcMembers
public final class ThreadingObjcBridge: NSObject {
    public static func dispatchMainThreadSafe(_ block: @escaping @MainActor () -> Void) {
        DispatchMainThreadSafe(block)
    }
}
