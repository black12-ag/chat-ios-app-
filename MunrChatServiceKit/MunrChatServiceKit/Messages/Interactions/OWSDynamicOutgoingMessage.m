//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSDynamicOutgoingMessage.h"
#import <MunrChatServiceKit/MunrChatServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef TESTABLE_BUILD

@interface OWSDynamicOutgoingMessage ()

@property (nonatomic, readonly) DynamicOutgoingMessageBlock block;

@end

#pragma mark -

@implementation OWSDynamicOutgoingMessage

- (instancetype)initWithThread:(TSThread *)thread
                   transaction:(DBReadTransaction *)transaction
            plainTextDataBlock:(DynamicOutgoingMessageBlock)block
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];

    if (self) {
        _block = block;
    }

    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (nullable NSData *)buildPlainTextData:(TSThread *)thread transaction:(DBWriteTransaction *)transaction
{
    NSData *plainTextData = self.block();
    OWSAssertDebug(plainTextData);
    return plainTextData;
}

@end

#endif

NS_ASSUME_NONNULL_END
