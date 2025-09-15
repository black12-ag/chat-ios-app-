//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/TSPaymentModels.h>

@protocol OWSPaymentMessage
@required

// Properties
@property (nonatomic, readonly, nullable) TSPaymentNotification *paymentNotification;

@end
