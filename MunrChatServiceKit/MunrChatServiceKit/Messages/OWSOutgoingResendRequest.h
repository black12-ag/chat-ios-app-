//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class AciObjC;
@class SSKProtoEnvelope;

@interface OWSOutgoingResendRequest : TSOutgoingMessage

- (instancetype)initWithErrorMessageBytes:(NSData *)errorMessageBytes
                                sourceAci:(AciObjC *)sourceAci
                    failedEnvelopeGroupId:(nullable NSData *)failedEnvelopeGroupId
                              transaction:(DBWriteTransaction *)transaction;

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<MunrChatServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<ServiceIdObjC *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<ServiceIdObjC *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

@end

@interface OWSOutgoingResendRequest (SwiftBridge)
@property (strong, nonatomic, readonly) NSData *decryptionErrorData;
@end

NS_ASSUME_NONNULL_END
