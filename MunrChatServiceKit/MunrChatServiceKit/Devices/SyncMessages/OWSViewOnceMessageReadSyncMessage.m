//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import "OWSViewOnceMessageReadSyncMessage.h"
#import <MunrChatServiceKit/MunrChatServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSViewOnceMessageReadSyncMessage ()
@property (nonatomic, readonly, nullable) NSString *messageUniqueId; // Only nil if decoding old values
@end

@implementation OWSViewOnceMessageReadSyncMessage

- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                          senderAci:(AciObjC *)senderAci
                            message:(TSMessage *)message
                      readTimestamp:(uint64_t)readTimestamp
                        transaction:(DBReadTransaction *)transaction
{
    OWSAssertDebug(message.timestamp > 0);

    self = [super initWithLocalThread:localThread transaction:transaction];
    if (!self) {
        return self;
    }

    _senderAddress = [[MunrChatServiceAddress alloc] initWithServiceIdObjC:senderAci];
    _messageUniqueId = message.uniqueId;
    _messageIdTimestamp = message.timestamp;
    _readTimestamp = readTimestamp;

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    if (_senderAddress == nil) {
        NSString *phoneNumber = [coder decodeObjectForKey:@"senderId"];
        _senderAddress = [MunrChatServiceAddress legacyAddressWithServiceIdString:nil phoneNumber:phoneNumber];
        OWSAssertDebug(_senderAddress.isValid);
    }

    return self;
}

- (BOOL)isUrgent
{
    return NO;
}

- (nullable SSKProtoSyncMessageBuilder *)syncMessageBuilderWithTransaction:(DBReadTransaction *)transaction
{
    SSKProtoSyncMessageBuilder *syncMessageBuilder = [SSKProtoSyncMessage builder];

    SSKProtoSyncMessageViewOnceOpenBuilder *readProtoBuilder =
        [SSKProtoSyncMessageViewOnceOpen builderWithTimestamp:self.messageIdTimestamp];
    readProtoBuilder.senderAci = self.senderAddress.aciString;
    NSError *error;
    SSKProtoSyncMessageViewOnceOpen *_Nullable readProto = [readProtoBuilder buildAndReturnError:&error];
    if (error || !readProto) {
        OWSFailDebug(@"could not build protobuf: %@", error);
        return nil;
    }
    [syncMessageBuilder setViewOnceOpen:readProto];

    return syncMessageBuilder;
}

- (NSSet<NSString *> *)relatedUniqueIds
{
    if (self.messageUniqueId) {
        return [[super relatedUniqueIds] setByAddingObject:self.messageUniqueId];
    } else {
        return [super relatedUniqueIds];
    }
}

@end

NS_ASSUME_NONNULL_END
