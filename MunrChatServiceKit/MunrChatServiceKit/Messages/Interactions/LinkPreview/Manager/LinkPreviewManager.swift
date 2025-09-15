//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol LinkPreviewManager {
    /// Uses the default builder.
    func validateAndBuildLinkPreview(
        from proto: SSKProtoPreview,
        dataMessage: SSKProtoDataMessage,
        tx: DBWriteTransaction
    ) throws -> OwnedAttachmentBuilder<OWSLinkPreview>

    func validateAndBuildLinkPreview<Builder: LinkPreviewBuilder>(
        from proto: SSKProtoPreview,
        dataMessage: SSKProtoDataMessage,
        builder: Builder,
        tx: DBWriteTransaction
    ) throws -> OwnedAttachmentBuilder<OWSLinkPreview>

    func validateAndBuildStoryLinkPreview(
        from proto: SSKProtoPreview,
        tx: DBWriteTransaction
    ) throws -> OwnedAttachmentBuilder<OWSLinkPreview>

    /// Uses the default builder.
    func buildDataSource(
        from draft: OWSLinkPreviewDraft
    ) async throws -> LinkPreviewDataSource

    func buildDataSource<Builder: LinkPreviewBuilder>(
        from draft: OWSLinkPreviewDraft,
        builder: Builder
    ) async throws -> LinkPreviewDataSource

    /// Uses the default builder.
    func buildLinkPreview(
        from dataSource: LinkPreviewDataSource,
        tx: DBWriteTransaction
    ) throws -> OwnedAttachmentBuilder<OWSLinkPreview>

    func buildLinkPreview<Builder: LinkPreviewBuilder>(
        from dataSource: LinkPreviewDataSource,
        builder: Builder,
        tx: DBWriteTransaction
    ) throws -> OwnedAttachmentBuilder<OWSLinkPreview>

    func buildProtoForSending(
        _ linkPreview: OWSLinkPreview,
        parentMessage: TSMessage,
        tx: DBReadTransaction
    ) throws -> SSKProtoPreview

    func buildProtoForSending(
        _ linkPreview: OWSLinkPreview,
        parentStoryMessage: StoryMessage,
        tx: DBReadTransaction
    ) throws -> SSKProtoPreview
}
