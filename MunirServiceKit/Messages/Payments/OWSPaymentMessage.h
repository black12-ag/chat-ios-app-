//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <MunirServiceKit/TSPaymentModels.h>

@protocol OWSPaymentMessage
@required

// Properties
@property (nonatomic, readonly, nullable) TSPaymentNotification *paymentNotification;

@end
