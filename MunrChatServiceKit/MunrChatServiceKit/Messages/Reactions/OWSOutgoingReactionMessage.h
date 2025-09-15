//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSReaction;

@interface OWSOutgoingReactionMessage : TSOutgoingMessage

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
                       message:(TSMessage *)message
                         emoji:(NSString *)emoji
                    isRemoving:(BOOL)isRemoving
              expiresInSeconds:(uint32_t)expiresInSeconds
            expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                   transaction:(DBReadTransaction *)transaction;

@property (nonatomic, readonly) NSString *messageUniqueId;
@property (nonatomic, readonly) NSString *emoji;
@property (nonatomic, readonly) BOOL isRemoving;
@property (nonatomic, nullable) OWSReaction *createdReaction;
@property (nonatomic, nullable) OWSReaction *previousReaction;

@end

NS_ASSUME_NONNULL_END
