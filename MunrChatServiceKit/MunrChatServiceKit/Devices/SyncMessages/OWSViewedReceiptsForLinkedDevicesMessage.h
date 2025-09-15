//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <Mantle/MTLModel.h>
#import <MunrChatServiceKit/OWSOutgoingSyncMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class AciObjC;
@class DBReadTransaction;
@class MunrChatServiceAddress;

@interface OWSLinkedDeviceViewedReceipt : MTLModel

@property (nonatomic, readonly) MunrChatServiceAddress *senderAddress;
@property (nonatomic, readonly, nullable) NSString *messageUniqueId; // Only nil if decoding old values
@property (nonatomic, readonly) uint64_t messageIdTimestamp;
@property (nonatomic, readonly) uint64_t viewedTimestamp;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSenderAci:(AciObjC *)senderAci
                  messageUniqueId:(nullable NSString *)messageUniqueId
               messageIdTimestamp:(uint64_t)messageIdTimestamp
                  viewedTimestamp:(uint64_t)viewedTimestamp NS_DESIGNATED_INITIALIZER;

@end

@interface OWSViewedReceiptsForLinkedDevicesMessage : OWSOutgoingSyncMessage

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                        transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;
- (instancetype)initWithTimestamp:(uint64_t)timestamp
                      localThread:(TSContactThread *)localThread
                      transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                     viewedReceipts:(NSArray<OWSLinkedDeviceViewedReceipt *> *)readReceipts
                        transaction:(DBReadTransaction *)transaction NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
