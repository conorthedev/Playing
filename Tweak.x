#import <Playing/libplaying.h>
#import <AppList/AppList.h>
#import <MediaRemote/MediaRemote.h>

static PlayingNotificationManager *notificationManager;
static PlayingManager *manager;
static PlayingPreferences *preferences;

%group MediaControllerHook
%hook SBMediaController
-(void)_setNowPlayingApplication:(SBApplication*)arg1 {
	%orig;
	manager.currentApp = arg1.bundleIdentifier;
}

-(void)setNowPlayingInfo:(id)arg1 {
	%orig;

	if(preferences.enabled) {
		dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.75);
    	dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {				
				NSString *currentID = @"";
				if([[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication]) {
					currentID = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier;
				}

				if(manager.currentApp && ![manager.currentApp isEqualToString:@""] && currentID && ![currentID isEqualToString:@""]) {
					if ([[preferences.preferences objectForKey:[@"blacklist-" stringByAppendingString:manager.currentApp]] boolValue] || 
						[[preferences.preferences objectForKey:[@"dontshow-" stringByAppendingString:currentID]] boolValue]) {
						return;
					}
				}
				
				[manager setMetadata:(__bridge NSDictionary *)information];
			});
		});
	}
}
%end
%end

%group BBServerManager
%hook BBServer
-(id)initWithQueue:(id)arg1 {
    notificationManager.bbServer = %orig;
    return notificationManager.bbServer;
}

-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    notificationManager.bbServer = %orig;
    return notificationManager.bbServer;
}

- (void)dealloc {
	if (notificationManager.bbServer == self) {
		notificationManager.bbServer = NULL;
	}

	%orig;
}
%end
%end

%group ShortLookFixer
%hook DDUserNotification 
- (NSString *)senderIdentifier {
	NSString *orig = %orig;
	if(!preferences.asMediaApp) {
		return orig;
	}

	if([orig isEqualToString:manager.currentApp]) {
		return @"me.conorthedev.playing";
	} else {
		return orig;
	}
}
%end
%end

%group debug
%hook BBBulletin
+(void)vetSortDescriptor:(id)arg1  { %log; %orig; }
+(id)validSortDescriptorsFromSortDescriptors:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
+(id)bulletinWithBulletin:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
+(id)bulletinReferenceDateFromDate:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
+(id)_lifeAssertionAssociationSet { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
+(id)_observerAssociationSet { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
+(BOOL)supportsSecureCoding { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)setPublicationDate:(NSDate *)arg1  { %log; %orig; }
-(NSDate *)publicationDate { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setHasEventDate:(BOOL)arg1  { %log; %orig; }
-(BOOL)hasEventDate { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)dateIsAllDay { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)setDateIsAllDay:(BOOL)arg1  { %log; %orig; }
-(NSDate *)recencyDate { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setRecencyDate:(NSDate *)arg1  { %log; %orig; }
-(NSString *)bulletinID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(long long)sectionSubtype { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(NSArray *)intentIDs { %log; NSArray * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)lifeAssertions { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)_fillOutCopy:(id)arg1 withZone:(NSZone*)arg2  { %log; %orig; }
-(NSString *)bulletinVersionID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)clearable { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSString *)unlockActionLabelOverride { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSMutableDictionary *)supplementaryActionsByLayout { %log; NSMutableDictionary * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(unsigned long long)expirationEvents { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(NSDate *)lastInterruptDate { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)usesExternalSync { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(unsigned long long)realertCount_deprecated { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(NSSet *)alertSuppressionAppIDs_deprecated { %log; NSSet * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_actionWithID:(id)arg1 fromActions:(id)arg2  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_allSupplementaryActions { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)responseSendBlock { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_responseForAction:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)firstValidObserver { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_actionKeyForType:(long long)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setAddressBookRecordID:(long long)arg1  { %log; %orig; }
-(void)setClearable:(BOOL)arg1  { %log; %orig; }
-(void)setUnlockActionLabelOverride:(NSString *)arg1  { %log; %orig; }
-(void)setSupplementaryActionsByLayout:(NSMutableDictionary *)arg1  { %log; %orig; }
-(void)setExpirationEvents:(unsigned long long)arg1  { %log; %orig; }
-(void)setLastInterruptDate:(NSDate *)arg1  { %log; %orig; }
-(void)setBulletinVersionID:(NSString *)arg1  { %log; %orig; }
-(void)setRealertCount_deprecated:(unsigned long long)arg1  { %log; %orig; }
-(void)setAlertSuppressionAppIDs_deprecated:(NSSet *)arg1  { %log; %orig; }
-(void)copyAssociationsForBulletin:(id)arg1  { %log; %orig; }
-(BOOL)hasPrivateContent { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)setHasPrivateContent:(BOOL)arg1  { %log; %orig; }
-(unsigned long long)numberOfAdditionalAttachmentsOfType:(long long)arg1  { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(id)_safeDescription:(BOOL)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(unsigned long long)numberOfAdditionalAttachments { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(id)responseForDefaultAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)responseForButtonActionAtIndex:(unsigned long long)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)responseForRaiseAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)responseForExpireAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)actionForResponse:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)safeDescription { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)expiresOnPublisherDeath { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)setExpiresOnPublisherDeath:(BOOL)arg1  { %log; %orig; }
-(void)addLifeAssertion:(id)arg1  { %log; %orig; }
-(BOOL)showsSubtitle { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)usesVariableLayout { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)orderSectionUsingRecencyDate { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)showsDateInFloatingLockScreenAlert { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSString *)missedBannerDescriptionFormat { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)bannerAccessoryRemoteViewControllerClassName { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)bannerAccessoryRemoteServiceBundleIdentifier { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)secondaryContentRemoteViewControllerClassName { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)secondaryContentRemoteServiceBundleIdentifier { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)preservesUnlockActionCase { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)visuallyIndicatesWhenDateIsInFuture { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)suppressesTitle { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)showsUnreadIndicatorForNoticesFeed { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)showsContactPhoto { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)playsSoundForModify { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(unsigned long long)subtypePriority { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(long long)iPodOutAlertType { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(BOOL)allowsAddingToLockScreenWhenUnlocked { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSSet *)alertSuppressionAppIDs { %log; NSSet * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_sectionParameters { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)_sectionSubtypeParameters { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)suppressesMessageForPrivacy { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(CGSize)composedAttachmentImageSizeWithObserver:(id)arg1  { %log; CGSize r = %orig; NSLog(@"[Playing] = {%g, %g}", r.width, r.height); return r; }
-(id)syncHash { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(unsigned long long)counter { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(void)setCounter:(unsigned long long)arg1  { %log; %orig; }
-(NSDate *)endDate { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setEndDate:(NSDate *)arg1  { %log; %orig; }
-(NSArray *)buttons { %log; NSArray * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setLoading:(BOOL)arg1  { %log; %orig; }
-(id)_allActions { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)showsMessagePreview { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSString *)dismissalID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)publisherBulletinID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(long long)primaryAttachmentType { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(void)setBulletinID:(NSString *)arg1  { %log; %orig; }
-(void)setUniversalSectionID:(NSString *)arg1  { %log; %orig; }
-(NSString *)universalSectionID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setPeopleIDs:(NSArray *)arg1  { %log; %orig; }
-(void)setShowsMessagePreview:(BOOL)arg1  { %log; %orig; }
-(id)responseForAcknowledgeAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)responseForSnoozeAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)threadID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setButtons:(NSArray *)arg1  { %log; %orig; }
-(void)setParentSectionID:(NSString *)arg1  { %log; %orig; }
-(NSString *)categoryID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setCategoryID:(NSString *)arg1  { %log; %orig; }
-(NSString *)topic { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setRecordID:(NSString *)arg1  { %log; %orig; }
-(void)setHasCriticalIcon:(BOOL)arg1  { %log; %orig; }
-(void)setTurnsOnDisplay:(BOOL)arg1  { %log; %orig; }
-(void)setIgnoresQuietMode:(BOOL)arg1  { %log; %orig; }
-(void)setIgnoresDowntime:(BOOL)arg1  { %log; %orig; }
-(void)setUsesExternalSync:(BOOL)arg1  { %log; %orig; }
-(void)setDismissalID:(NSString *)arg1  { %log; %orig; }
-(void)setSectionSubtype:(long long)arg1  { %log; %orig; }
-(void)setThreadID:(NSString *)arg1  { %log; %orig; }
-(void)setIntentIDs:(NSArray *)arg1  { %log; %orig; }
-(void)setSubsectionIDs:(NSSet *)arg1  { %log; %orig; }
-(void)setWantsFullscreenPresentation:(BOOL)arg1  { %log; %orig; }
-(void)setPreventAutomaticRemovalFromLockScreen:(BOOL)arg1  { %log; %orig; }
-(id)actionWithIdentifier:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)primaryAttachment { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSArray *)additionalAttachments { %log; NSArray * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setAdditionalAttachments:(NSArray *)arg1  { %log; %orig; }
-(void)setDateFormatStyle:(long long)arg1  { %log; %orig; }
-(long long)dateFormatStyle { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(unsigned long long)messageNumberOfLines { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(id)responseForAction:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)publisherMatchID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(long long)contentPreviewSetting { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(id)supplementaryActions { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSSet *)subsectionIDs { %log; NSSet * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSArray *)peopleIDs { %log; NSArray * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)parentSectionID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)hasCriticalIcon { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSString *)hiddenPreviewsBodyPlaceholder { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)subtypeSummaryFormat { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)summaryArgument { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setSummaryArgument:(NSString *)arg1  { %log; %orig; }
-(unsigned long long)summaryArgumentCount { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(void)setSummaryArgumentCount:(unsigned long long)arg1  { %log; %orig; }
-(id)composedAttachmentImageWithObserver:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSSet *)alertSuppressionContexts { %log; NSSet * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setAlertSuppressionContexts:(NSSet *)arg1  { %log; %orig; }
-(NSString *)fullAlternateActionLabel { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)fullUnlockActionLabel { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)alternateActionLabel { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)unlockActionLabel { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)ignoresQuietMode { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)ignoresDowntime { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)inertWhenLocked { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)allowsAutomaticRemovalFromLockScreen { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)preventAutomaticRemovalFromLockScreen { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(long long)lockScreenPriority { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(BOOL)prioritizeAtTopOfLockScreen { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)setLockScreenPriority:(long long)arg1  { %log; %orig; }
-(BOOL)canBeSilencedByMenuButtonPress { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(unsigned long long)realertCount { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(BOOL)suppressesAlertsWhenAppIsActive { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)turnsOnDisplay { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)wantsFullscreenPresentation { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)preemptsPresentedAlert { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)revealsAdditionalContentOnPresentation { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)sectionDisplaysCriticalBulletins { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(unsigned long long)privacySettings { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(void)setContentPreviewSetting:(long long)arg1  { %log; %orig; }
-(BOOL)coalescesWhenLocked { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)preventLock { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(BOOL)shouldDismissBulletinWhenClosed { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(id)silenceAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setSilenceAction:(id)arg1  { %log; %orig; }
-(long long)addressBookRecordID { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(id)supplementaryActionsForLayout:(long long)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setPublisherBulletinID:(NSString *)arg1  { %log; %orig; }
-(NSString *)sectionDisplayName { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)init { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)dealloc { %log; %orig; }
-(BOOL)isEqual:(id)arg1  { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(void)encodeWithCoder:(id)arg1  { %log; %orig; }
-(id)initWithCoder:(id)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(unsigned long long)hash { %log; unsigned long long r = %orig; NSLog(@"[Playing] = %llu", r); return r; }
-(id)description { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setTitle:(NSString *)arg1  { %log; %orig; }
-(NSString *)title { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(id)copyWithZone:(NSZone*)arg1  { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)section { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setMessage:(NSString *)arg1  { %log; %orig; }
-(NSString *)message { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSMutableDictionary *)actions { %log; NSMutableDictionary * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setSubtitle:(NSString *)arg1  { %log; %orig; }
-(NSString *)subtitle { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setContext:(NSDictionary *)arg1  { %log; %orig; }
-(NSDictionary *)context { %log; NSDictionary * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSString *)sectionID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setSectionID:(NSString *)arg1  { %log; %orig; }
-(NSDate *)date { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)addObserver:(id)arg1  { %log; %orig; }
-(void)setSection:(NSString *)arg1  { %log; %orig; }
-(void)setBackgroundStyle:(long long)arg1  { %log; %orig; }
-(void)setHeader:(NSString *)arg1  { %log; %orig; }
-(NSString *)header { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSTimeZone *)timeZone { %log; NSTimeZone * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setTimeZone:(NSTimeZone *)arg1  { %log; %orig; }
-(void)setDate:(NSDate *)arg1  { %log; %orig; }
-(long long)backgroundStyle { %log; long long r = %orig; NSLog(@"[Playing] = %lld", r); return r; }
-(id)shortDescription { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(NSDate *)expirationDate { %log; NSDate * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(void)setExpirationDate:(NSDate *)arg1  { %log; %orig; }
-(void)setActions:(NSMutableDictionary *)arg1  { %log; %orig; }
-(void)setDismissAction:(id)arg1  { %log; %orig; }
-(id)dismissAction { %log; id r = %orig; NSLog(@"[Playing] = %@", r); return r; }
-(BOOL)isLoading { %log; BOOL r = %orig; NSLog(@"[Playing] = %d", r); return r; }
-(NSString *)recordID { %log; NSString * r = %orig; NSLog(@"[Playing] = %@", r); return r; }
%end
%end

%ctor {
	notificationManager = [PlayingNotificationManager sharedInstance];
	manager = [PlayingManager sharedInstance];
	preferences = [PlayingPreferences sharedInstance];

	NSString *shortlookPath = @"/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib";
	if ([[NSFileManager defaultManager] fileExistsAtPath:shortlookPath]){
		dlopen("/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib", RTLD_LAZY);
		%init(ShortLookFixer);
	}
	
	%init(BBServerManager);
	%init(MediaControllerHook);
	//%init(debug);
}