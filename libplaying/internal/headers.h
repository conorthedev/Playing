#import <dlfcn.h>
#import <objc/runtime.h>
//#import <MediaRemote/MediaRemote.h>

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkIdentifier;
extern CFStringRef kMRMediaRemoteNowPlayingInfoContentItemIdentifier;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkDataHeight;

@class BBBulletin;
@interface BBServer : NSObject
-(void)publishBulletin:(BBBulletin*)arg1 destinations:(unsigned long long)arg2 ;
-(void)_clearSection:(NSString*)arg1;
@end

@interface BBAction : NSObject
+(id)actionWithLaunchBundleID:(id)arg1;
@end

@interface BBResponse : NSObject
@property (nonatomic, copy) NSString *bulletinID;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString *bundleIdentifier;
@end

@interface SpringBoard : NSObject
+(id)sharedApplication;
-(SBApplication*)_accessibilityFrontMostApplication;
@end

@interface SBMediaController : NSObject
-(SBApplication *)nowPlayingApplication;
@end

@interface BBBulletin : NSObject
@property (nonatomic, copy) BBAction *acknowledgeAction;
@property (nonatomic, retain) NSMutableDictionary *actions;
@property (nonatomic, copy) NSArray *additionalAttachments;
@property (nonatomic) long long addressBookRecordID;
@property (nonatomic, readonly) NSSet *alertSuppressionAppIDs;
@property (nonatomic, copy) NSSet *alertSuppressionAppIDs_deprecated;
@property (nonatomic, copy) NSSet *alertSuppressionContexts;
@property (nonatomic, readonly) bool allowsAddingToLockScreenWhenUnlocked;
@property (nonatomic, readonly) bool allowsAutomaticRemovalFromLockScreen;
@property (nonatomic, copy) BBAction *alternateAction;
@property (nonatomic, readonly) NSString *alternateActionLabel;
@property (nonatomic) long long backgroundStyle;
@property (nonatomic, readonly) NSString *bannerAccessoryRemoteServiceBundleIdentifier;
@property (nonatomic, readonly) NSString *bannerAccessoryRemoteViewControllerClassName;
@property (nonatomic, copy) NSString *bulletinID;
@property (nonatomic, copy) NSString *bulletinVersionID;
@property (nonatomic, copy) NSArray *buttons;
@property (nonatomic, readonly) bool canBeSilencedByMenuButtonPress;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic) bool clearable;
@property (nonatomic, readonly) bool coalescesWhenLocked;
@property (nonatomic) long long contentPreviewSetting;
@property (nonatomic, retain) NSDictionary *context;
@property (nonatomic) unsigned long long counter;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic) long long dateFormatStyle;
@property (nonatomic) bool dateIsAllDay;
@property (nonatomic, copy) BBAction *defaultAction;
@property (nonatomic, copy) NSString *dismissalID;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic) unsigned long long expirationEvents;
@property (nonatomic, copy) BBAction *expireAction;
@property (nonatomic) bool expiresOnPublisherDeath;
@property (nonatomic, readonly) NSString *fullAlternateActionLabel;
@property (nonatomic, readonly) NSString *fullUnlockActionLabel;
@property (nonatomic) bool hasCriticalIcon;
@property (nonatomic) bool hasEventDate;
@property (nonatomic) bool hasPrivateContent;
@property (nonatomic, copy) NSString *header;
@property (nonatomic, readonly) NSString *hiddenPreviewsBodyPlaceholder;
@property (nonatomic, readonly) long long iPodOutAlertType;
@property (nonatomic) bool ignoresDowntime;
@property (nonatomic) bool ignoresQuietMode;
@property (nonatomic, readonly) bool inertWhenLocked;
@property (nonatomic, copy) NSArray *intentIDs;
@property (nonatomic, retain) NSDate *lastInterruptDate;
@property (getter=isLoading, nonatomic) bool loading;
@property (nonatomic) long long lockScreenPriority;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly) unsigned long long messageNumberOfLines;
@property (nonatomic, readonly) NSString *missedBannerDescriptionFormat;
@property (nonatomic, readonly) bool orderSectionUsingRecencyDate;
@property (nonatomic, copy) NSString *parentSectionID;
@property (nonatomic, copy) NSArray *peopleIDs;
@property (nonatomic, readonly) bool playsSoundForModify;
@property (nonatomic, readonly) bool preemptsPresentedAlert;
@property (nonatomic, readonly) bool preservesUnlockActionCase;
@property (nonatomic) bool preventAutomaticRemovalFromLockScreen;
@property (nonatomic, readonly) bool preventLock;
//@property (nonatomic, copy) BBAttachmentMetadata *primaryAttachment;
@property (nonatomic, readonly) bool prioritizeAtTopOfLockScreen;
@property (nonatomic, readonly) unsigned long long privacySettings;
@property (nonatomic, retain) NSDate *publicationDate;
@property (nonatomic, copy) NSString *publisherBulletinID;
@property (nonatomic, readonly, copy) NSString *publisherMatchID;
@property (nonatomic, copy) BBAction *raiseAction;
@property (nonatomic, readonly) unsigned long long realertCount;
@property (nonatomic) unsigned long long realertCount_deprecated;
@property (nonatomic, retain) NSDate *recencyDate;
@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, readonly) bool revealsAdditionalContentOnPresentation;
@property (nonatomic, readonly) NSString *secondaryContentRemoteServiceBundleIdentifier;
@property (nonatomic, readonly) NSString *secondaryContentRemoteViewControllerClassName;
@property (nonatomic, copy) NSString *section;
@property (nonatomic, readonly) NSString *sectionDisplayName;
@property (nonatomic, readonly) bool sectionDisplaysCriticalBulletins;
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic) long long sectionSubtype;
@property (nonatomic, readonly) bool shouldDismissBulletinWhenClosed;
@property (nonatomic, readonly) bool showsContactPhoto;
@property (nonatomic, readonly) bool showsDateInFloatingLockScreenAlert;
@property (nonatomic, readonly) bool showsSubtitle;
@property (nonatomic, readonly) bool showsUnreadIndicatorForNoticesFeed;
@property (nonatomic, copy) BBAction *snoozeAction;
@property (nonatomic, copy) NSSet *subsectionIDs;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) unsigned long long subtypePriority;
@property (nonatomic, readonly) NSString *subtypeSummaryFormat;
@property (nonatomic, copy) NSString *summaryArgument;
@property (nonatomic) unsigned long long summaryArgumentCount;
@property (nonatomic, retain) NSMutableDictionary *supplementaryActionsByLayout;
@property (nonatomic, readonly) bool suppressesAlertsWhenAppIsActive;
@property (nonatomic, readonly) bool suppressesMessageForPrivacy;
@property (nonatomic, readonly) bool suppressesTitle;
@property (nonatomic, copy) NSString *threadID;
@property (nonatomic, retain) NSTimeZone *timeZone;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) NSString *topic;
@property (nonatomic) bool turnsOnDisplay;
@property (nonatomic, copy) NSString *universalSectionID;
@property (nonatomic, readonly) NSString *unlockActionLabel;
@property (nonatomic, copy) NSString *unlockActionLabelOverride;
@property (nonatomic) bool usesExternalSync;
@property (nonatomic, readonly) bool usesVariableLayout;
@property (nonatomic, readonly) bool visuallyIndicatesWhenDateIsInFuture;
@property (nonatomic) bool wantsFullscreenPresentation;

@end