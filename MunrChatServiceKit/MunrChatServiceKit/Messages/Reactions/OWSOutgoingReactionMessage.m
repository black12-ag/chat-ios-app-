//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSOutgoingReactionMessage.h"
#import <MunrChatServiceKit/MunrChatServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSOutgoingReactionMessage

- (instancetype)initWithThread:(TSThread *)thread
                       message:(TSMessage *)message
                         emoji:(NSString *)emoji
                    isRemoving:(BOOL)isRemoving
              expiresInSeconds:(uint32_t)expiresInSeconds
            expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                   transaction:(DBReadTransaction *)transaction
{
    OWSAssertDebug([thread.uniqueId isEqualToString:message.uniqueThreadId]);
    OWSAssertDebug(emoji.isSingleEmoji);

    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    messageBuilder.expiresInSeconds = expiresInSeconds;
    messageBuilder.expireTimerVersion = expireTimerVersion;
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
    if (!self) {
        return self;
    }

    _messageUniqueId = message.uniqueId;
    _emoji = emoji;
    _isRemoving = isRemoving;

    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (nullable SSKProtoDataMessageBuilder *)dataMessageBuilderWithThread:(TSThread *)thread
                                                          transaction:(DBReadTransaction *)transaction
{
    SSKProtoDataMessageReaction *_Nullable reactionProto = [self buildDataMessageReactionProtoWithTx:transaction];
    if (!reactionProto) {
        return nil;
    }

    SSKProtoDataMessageBuilder *builder = [super dataMessageBuilderWithThread:thread transaction:transaction];
    [builder setTimestamp:self.timestamp];
    [builder setReaction:reactionProto];
    [builder setRequiredProtocolVersion:SSKProtoDataMessageProtocolVersionReactions];

    return builder;
}

- (NSSet<NSString *> *)relatedUniqueIds
{
    return [[super relatedUniqueIds] setByAddingObjectsFromArray:@[ self.messageUniqueId ]];
}

@end

NS_ASSUME_NONNULL_END
