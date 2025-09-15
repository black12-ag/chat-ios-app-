//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#import <Foundation/Foundation.h>

//! Project version number for MunirServiceKit.
FOUNDATION_EXPORT double MunirServiceKitVersionNumber;

//! Project version string for MunirServiceKit.
FOUNDATION_EXPORT const unsigned char MunirServiceKitVersionString[];

#import <MunirServiceKit/BaseModel.h>
#import <MunirServiceKit/DebuggerUtils.h>
#import <MunirServiceKit/InstalledSticker.h>
#import <MunirServiceKit/OWSAddToContactsOfferMessage.h>
#import <MunirServiceKit/OWSAddToProfileWhitelistOfferMessage.h>
#import <MunirServiceKit/OWSArchivedPaymentMessage.h>
#import <MunirServiceKit/OWSAsserts.h>
#import <MunirServiceKit/OWSBlockedPhoneNumbersMessage.h>
#import <MunirServiceKit/OWSDisappearingConfigurationUpdateInfoMessage.h>
#import <MunirServiceKit/OWSDisappearingMessagesConfiguration.h>
#import <MunirServiceKit/OWSDisappearingMessagesConfigurationMessage.h>
#import <MunirServiceKit/OWSDynamicOutgoingMessage.h>
#import <MunirServiceKit/OWSEndSessionMessage.h>
#import <MunirServiceKit/OWSGroupCallMessage.h>
#import <MunirServiceKit/OWSIncomingArchivedPaymentMessage.h>
#import <MunirServiceKit/OWSIncomingPaymentMessage.h>
#import <MunirServiceKit/OWSLinkedDeviceReadReceipt.h>
#import <MunirServiceKit/OWSLogs.h>
#import <MunirServiceKit/OWSOutgoingArchivedPaymentMessage.h>
#import <MunirServiceKit/OWSOutgoingCallMessage.h>
#import <MunirServiceKit/OWSOutgoingNullMessage.h>
#import <MunirServiceKit/OWSOutgoingPaymentMessage.h>
#import <MunirServiceKit/OWSOutgoingReactionMessage.h>
#import <MunirServiceKit/OWSOutgoingResendRequest.h>
#import <MunirServiceKit/OWSOutgoingSenderKeyDistributionMessage.h>
#import <MunirServiceKit/OWSOutgoingSentMessageTranscript.h>
#import <MunirServiceKit/OWSOutgoingSyncMessage.h>
#import <MunirServiceKit/OWSPaymentActivationRequestFinishedMessage.h>
#import <MunirServiceKit/OWSPaymentActivationRequestMessage.h>
#import <MunirServiceKit/OWSPaymentMessage.h>
#import <MunirServiceKit/OWSProfileKeyMessage.h>
#import <MunirServiceKit/OWSReadReceiptsForLinkedDevicesMessage.h>
#import <MunirServiceKit/OWSReadTracking.h>
#import <MunirServiceKit/OWSReceiptsForSenderMessage.h>
#import <MunirServiceKit/OWSRecoverableDecryptionPlaceholder.h>
#import <MunirServiceKit/OWSStaticOutgoingMessage.h>
#import <MunirServiceKit/OWSStickerPackSyncMessage.h>
#import <MunirServiceKit/OWSSyncConfigurationMessage.h>
#import <MunirServiceKit/OWSSyncFetchLatestMessage.h>
#import <MunirServiceKit/OWSSyncKeysMessage.h>
#import <MunirServiceKit/OWSSyncMessageRequestResponseMessage.h>
#import <MunirServiceKit/OWSSyncRequestMessage.h>
#import <MunirServiceKit/OWSUnknownContactBlockOfferMessage.h>
#import <MunirServiceKit/OWSUnknownProtocolVersionMessage.h>
#import <MunirServiceKit/OWSVerificationState.h>
#import <MunirServiceKit/OWSVerificationStateChangeMessage.h>
#import <MunirServiceKit/OWSVerificationStateSyncMessage.h>
#import <MunirServiceKit/OWSViewOnceMessageReadSyncMessage.h>
#import <MunirServiceKit/OWSViewedReceiptsForLinkedDevicesMessage.h>
#import <MunirServiceKit/OutgoingPaymentSyncMessage.h>
#import <MunirServiceKit/SDSDatabaseStorage+Objc.h>
#import <MunirServiceKit/SSKAccessors+SDS.h>
#import <MunirServiceKit/StickerInfo.h>
#import <MunirServiceKit/StickerPack.h>
#import <MunirServiceKit/TSCall.h>
#import <MunirServiceKit/TSContactThread.h>
#import <MunirServiceKit/TSErrorMessage.h>
#import <MunirServiceKit/TSGroupModel.h>
#import <MunirServiceKit/TSGroupThread.h>
#import <MunirServiceKit/TSIncomingMessage.h>
#import <MunirServiceKit/TSInfoMessage.h>
#import <MunirServiceKit/TSInteraction.h>
#import <MunirServiceKit/TSInvalidIdentityKeyErrorMessage.h>
#import <MunirServiceKit/TSInvalidIdentityKeyReceivingErrorMessage.h>
#import <MunirServiceKit/TSInvalidIdentityKeySendingErrorMessage.h>
#import <MunirServiceKit/TSMessage.h>
#import <MunirServiceKit/TSOutgoingDeleteMessage.h>
#import <MunirServiceKit/TSOutgoingMessage.h>
#import <MunirServiceKit/TSPaymentModel.h>
#import <MunirServiceKit/TSPaymentModels.h>
#import <MunirServiceKit/TSPrivateStoryThread.h>
#import <MunirServiceKit/TSQuotedMessage.h>
#import <MunirServiceKit/TSThread.h>
#import <MunirServiceKit/TSUnreadIndicatorInteraction.h>
#import <MunirServiceKit/TSYapDatabaseObject.h>
#import <MunirServiceKit/Threading.h>

#define OWSLocalizedString(key, comment)                                                                               \
    [[NSBundle mainBundle].appBundle localizedStringForKey:(key) value:@"" table:nil]
