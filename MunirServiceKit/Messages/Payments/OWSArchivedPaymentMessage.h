//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <MunirServiceKit/TSPaymentModels.h>

#ifndef OWSRestoredPayment_h
#define OWSRestoredPayment_h

@protocol OWSArchivedPaymentMessage
@required
@property (nonatomic, readonly) TSArchivedPaymentInfo *archivedPaymentInfo;
@end

#endif /* OWSRestoredPayment_h */
