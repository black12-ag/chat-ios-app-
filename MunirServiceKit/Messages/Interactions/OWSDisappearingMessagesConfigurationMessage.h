//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <MunirServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSDisappearingMessagesConfiguration;

@interface OWSDisappearingMessagesConfigurationMessage : TSOutgoingMessage

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<ServiceIdObjC *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<ServiceIdObjC *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithConfiguration:(OWSDisappearingMessagesConfiguration *)configuration
                               thread:(TSThread *)thread
                          transaction:(DBReadTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
