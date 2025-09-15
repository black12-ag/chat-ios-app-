//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import <MunrChatServiceKit/TSPaymentModels.h>

#ifndef OWSRestoredPayment_h
#define OWSRestoredPayment_h

@protocol OWSArchivedPaymentMessage
@required
@property (nonatomic, readonly) TSArchivedPaymentInfo *archivedPaymentInfo;
@end

#endif /* OWSRestoredPayment_h */
