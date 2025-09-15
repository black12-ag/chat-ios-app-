//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// Priority at which we download attachments.
///
/// Priority determines:
/// * Order in which we download (higher priority first)
/// * Whether we download while there is an active call (must be user initiated)
/// * Whether we download while the thread is in a message request state (must be user initiated)
/// * Whether we bypass auto-download settings (must be user initiated)
///
public enum AttachmentDownloadPriority: Int, Codable {

    /// Backups enqueue downloads at priority lower than default.
    case backupRestore = 20

    case `default` = 50

    case userInitiated = 100

    /// Used if, at attachment creation/insertion time, we have a local source to pull from.
    /// There are two cases:
    /// * Incoming sticker message for a sticker pack we have installed
    /// * Quoted reply for an original attachment we have downloaded
    ///     > Typically, this happens if we receive an incoming quoted reply,
    ///     but may also be if we downloaded the original between when we
    ///     initiated an outgoing quoted reply and when we actually saved it.
    ///
    /// In these cases, we immediately "download" (regardless of settings, hence higher
    /// than user initiated) but the actual "download" exclusively uses the local source
    /// and, if that fails, re-enqueues at lower default priority.
    case localClone = 200

    public init?(rawValue: Int) {
        switch rawValue {
        case Self.backupRestore.rawValue:
            self = .backupRestore
        case Self.default.rawValue:
            self = .default
        case Self.userInitiated.rawValue:
            self = .userInitiated
        case Self.localClone.rawValue:
            self = .localClone
        case 25:
            // legacy case that used to represent a "higher"
            // priority of `backupRestore`, which we now collapse
            // into `backupRestore`.
            self = .backupRestore
        default:
            return nil
        }
    }
}
