//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/OWSOutgoingSyncMessage.h>
#import <MunrChatServiceKit/OWSVerificationState.h>

NS_ASSUME_NONNULL_BEGIN

@class MunrChatServiceAddress;

@interface OWSVerificationStateSyncMessage : OWSOutgoingSyncMessage

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                        transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;
- (instancetype)initWithTimestamp:(uint64_t)timestamp
                      localThread:(TSContactThread *)localThread
                      transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                  verificationState:(OWSVerificationState)verificationState
                        identityKey:(NSData *)identityKey
    verificationForRecipientAddress:(MunrChatServiceAddress *)address
                        transaction:(DBReadTransaction *)transaction NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

// This is a clunky name, but we want to differentiate it from `recipientIdentifier` inherited from `TSOutgoingMessage`
@property (nonatomic, readonly) MunrChatServiceAddress *verificationForRecipientAddress;

@property (nonatomic, readonly) size_t paddingBytesLength;
@property (nonatomic, readonly) size_t unpaddedVerifiedLength;

@end

NS_ASSUME_NONNULL_END
