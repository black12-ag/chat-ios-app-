//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <MunirServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

// A generic, serializable message that can be used to
// send fixed plaintextData payloads.
@interface OWSStaticOutgoingMessage : TSOutgoingMessage

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<ServiceIdObjC *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<ServiceIdObjC *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithThread:(TSThread *)thread
                     timestamp:(uint64_t)timestamp
                 plaintextData:(NSData *)plaintextData
                   transaction:(DBReadTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
