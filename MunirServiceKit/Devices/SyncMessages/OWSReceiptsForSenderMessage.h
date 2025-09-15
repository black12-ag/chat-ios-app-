//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <MunirServiceKit/OWSOutgoingSyncMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSDeliveryReceipt, MessageReceiptSet;

@interface OWSReceiptsForSenderMessage : TSOutgoingMessage

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<ServiceIdObjC *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<ServiceIdObjC *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

+ (OWSReceiptsForSenderMessage *)deliveryReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                                 receiptSet:(MessageReceiptSet *)receiptSet
                                                                transaction:(DBReadTransaction *)transaction;

+ (OWSReceiptsForSenderMessage *)readReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                             receiptSet:(MessageReceiptSet *)receiptSet
                                                            transaction:(DBReadTransaction *)transaction
    NS_SWIFT_NAME(readReceiptsForSenderMessage(with:receiptSet:transaction:));

+ (OWSReceiptsForSenderMessage *)viewedReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                               receiptSet:(MessageReceiptSet *)receiptSet
                                                              transaction:(DBReadTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
