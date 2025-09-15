//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSOutgoingSenderKeyDistributionMessage.h"
#import <MunirServiceKit/MunirServiceKit-Swift.h>

@interface OWSOutgoingSenderKeyDistributionMessage ()
@property (strong, nonatomic, readonly) NSData *serializedSKDM;
@property (assign, atomic) BOOL isSentOnBehalfOfOnlineMessage;
@property (assign, atomic) BOOL isSentOnBehalfOfStoryMessage;
@end

@implementation OWSOutgoingSenderKeyDistributionMessage

- (instancetype)initWithThread:(TSContactThread *)destinationThread
    senderKeyDistributionMessageBytes:(NSData *)skdmBytes
                          transaction:(DBReadTransaction *)transaction
{
    OWSAssertDebug(destinationThread);
    OWSAssertDebug(skdmBytes);
    if (!destinationThread || !skdmBytes) {
        return nil;
    }

    TSOutgoingMessageBuilder *messageBuilder =
        [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:destinationThread];
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
    if (self) {
        _serializedSKDM = [skdmBytes copy];
    }
    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (BOOL)isUrgent
{
    return NO;
}

- (BOOL)isStorySend
{
    return self.isSentOnBehalfOfStoryMessage;
}

- (SealedSenderContentHint)contentHint
{
    return SealedSenderContentHintImplicit;
}

- (nullable SSKProtoContentBuilder *)contentBuilderWithThread:(TSThread *)thread
                                                  transaction:(DBReadTransaction *)transaction
{
    SSKProtoContentBuilder *builder = [SSKProtoContent builder];
    [builder setSenderKeyDistributionMessage:self.serializedSKDM];
    return builder;
}

- (void)configureAsSentOnBehalfOf:(TSOutgoingMessage *)message inThread:(TSThread *)thread
{
    self.isSentOnBehalfOfOnlineMessage = message.isOnline;
    self.isSentOnBehalfOfStoryMessage = message.isStorySend && !thread.isGroupThread;
}

@end
