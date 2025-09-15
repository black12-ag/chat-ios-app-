//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef TESTABLE_BUILD

typedef NSData *_Nonnull (^DynamicOutgoingMessageBlock)(void);

/// This class is only used in debug tools
@interface OWSDynamicOutgoingMessage : TSOutgoingMessage

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<MunrChatServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<ServiceIdObjC *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<ServiceIdObjC *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithThread:(TSThread *)thread
                   transaction:(DBReadTransaction *)transaction
            plainTextDataBlock:(DynamicOutgoingMessageBlock)block;

@end

#endif

NS_ASSUME_NONNULL_END
