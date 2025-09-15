//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit
import MunirUI

class EditCallLinkNameViewController: NameEditorViewController {
    /// Values taken from the spec.
    override class var nameByteLimit: Int { 119 }
    override class var nameGlyphLimit: Int { 32 }

    override var placeholderText: String? { CallLinkState.defaultLocalizedName }

    override init(oldName: String, setNewName: @escaping (String) async throws -> Void) {
        super.init(oldName: oldName, setNewName: setNewName)
        self.title = oldName.isEmpty ? CallStrings.addCallName : CallStrings.editCallName
    }

    override func handleError(_ error: any Error) {
        Logger.warn("Call link edit name failed with error \(error)")
        OWSActionSheets.showActionSheet(
            title: CallStrings.callLinkErrorSheetTitle,
            message: CallStrings.callLinkUpdateErrorSheetDescription
        )
    }
}
