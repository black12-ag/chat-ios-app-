//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSOutgoingResendRequest.h"
#import <MunrChatServiceKit/MunrChatServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSOutgoingResendRequest ()
@property (strong, nonatomic, readonly) NSData *decryptionErrorData;
@property (strong, nonatomic, nullable, readonly) NSData *failedEnvelopeGroupId;
@end

@implementation OWSOutgoingResendRequest

- (instancetype)initWithErrorMessageBytes:(NSData *)errorMessageBytes
                                sourceAci:(AciObjC *)sourceAci
                    failedEnvelopeGroupId:(nullable NSData *)failedEnvelopeGroupId
                              transaction:(DBWriteTransaction *)transaction
{
    OWSAssertDebug(errorMessageBytes);
    OWSAssertDebug(sourceAci);
    OWSAssertDebug(transaction);

    MunrChatServiceAddress *sender = [[MunrChatServiceAddress alloc] initWithServiceIdObjC:sourceAci];
    TSContactThread *thread = [TSContactThread getOrCreateThreadWithContactAddress:sender transaction:transaction];
    TSOutgoingMessageBuilder *builder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    self = [super initOutgoingMessageWithBuilder:builder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
    if (self) {
        _decryptionErrorData = [errorMessageBytes copy];
        _failedEnvelopeGroupId = [failedEnvelopeGroupId copy];
    }
    return self;
}

- (EncryptionStyle)encryptionStyle
{
    return EncryptionStylePlaintext;
}

- (BOOL)isUrgent
{
    return NO;
}

- (BOOL)shouldRecordSendLog
{
    /// We have to return NO since our preferred style is Plaintext. If we returned YES, a future resend response would
    /// encrypt since MessageSender only deals with plaintext as Data. This is fine since its contentHint is `default`
    /// anyway.
    /// TODO: Maybe we should explore having a first class type to represent the plaintext message content mid-send?
    /// That way we don't need to call back to the original TSOutgoingMessage for questions about the plaintext. This
    /// makes sense in a world where the TSOutgoingMessage is divorced from the constructed plaintext because of the
    /// MessageSendLog and OWSOutgoingResendResponse
    return NO;
}

- (BOOL)shouldSyncTranscript
{
    return NO;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (SealedSenderContentHint)contentHint
{
    return SealedSenderContentHintDefault;
}

- (nullable NSData *)envelopeGroupIdWithTransaction:(__unused DBReadTransaction *)transaction
{
    return self.failedEnvelopeGroupId;
}

@end

NS_ASSUME_NONNULL_END
