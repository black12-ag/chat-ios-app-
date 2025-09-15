//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSEndSessionMessage.h"
#import <MunirServiceKit/MunirServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSEndSessionMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (instancetype)initWithThread:(TSThread *)thread transaction:(DBReadTransaction *)transaction
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    return [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (nullable SSKProtoDataMessageBuilder *)dataMessageBuilderWithThread:(TSThread *)thread
                                                          transaction:(DBReadTransaction *)transaction
{
    SSKProtoDataMessageBuilder *_Nullable builder = [super dataMessageBuilderWithThread:thread transaction:transaction];
    if (!builder) {
        return nil;
    }
    [builder setTimestamp:self.timestamp];
    [builder setFlags:SSKProtoDataMessageFlagsEndSession];

    return builder;
}

@end

NS_ASSUME_NONNULL_END
