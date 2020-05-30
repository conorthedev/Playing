#import <Playing/libplaying.h>
#import <Cephei/HBPreferences.h>
#import <MediaRemote/MediaRemote.h>
#import <AppList/AppList.h>

static HBPreferences *preferences = NULL;
static NSString *previousTitle = @"";

BOOL enabled;
NSString *customText = @"";

void SendTestNotification(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
	[[PlayingNotificationHelper sharedInstance] submitTestNotification:customText];
}

%hook SBMediaController

-(void)setNowPlayingInfo:(id)arg1 {
	%orig;
	if(enabled) {
		NSString *bundleID = [self nowPlayingApplication].bundleIdentifier;
		SBApplication *currentApp = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];

		if ([[preferences objectForKey:[@"blacklist-" stringByAppendingString:bundleID]] boolValue]) {
			return;
		}

		if(currentApp != NULL || currentApp.bundleIdentifier == NULL || [currentApp.bundleIdentifier isEqualToString:@""]) {
			if ([[preferences objectForKey:[@"dontshow-" stringByAppendingString:currentApp.bundleIdentifier]] boolValue]) {
				return;
			}
		}
		
		dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.75);
    	dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
				NSMutableDictionary *dict = [(__bridge NSDictionary *)information mutableCopy];
				[dict setObject:customText forKey:@"customText"];
				[dict setObject:bundleID forKey:@"bundleID"];

				[[PlayingManager sharedInstance] setMetadata:dict];
			});
		});
	}
}

%end

%hook BBServer
-(id)initWithQueue:(id)arg1 {
    [PlayingNotificationHelper sharedInstance].bbServer = %orig;
    return [PlayingNotificationHelper sharedInstance].bbServer;
}

-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    [PlayingNotificationHelper sharedInstance].bbServer = %orig;
    return [PlayingNotificationHelper sharedInstance].bbServer;
}

- (void)dealloc {
	if ([PlayingNotificationHelper sharedInstance].bbServer == self) {
		[PlayingNotificationHelper sharedInstance].bbServer = NULL;
	}

	%orig;
}

-(void)publishBulletin:(BBBulletin *)bulletin destinations:(unsigned int)arg2 {
	if(([[[PlayingManager sharedInstance] getCurrentApp] isEqualToString:@""] || ![PlayingNotificationHelper sharedInstance].sendingTest)) {
		if(![bulletin.sectionID isEqualToString:@"me.conorthedev.playing"]) {
			return;
		}
	}

	bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:[[PlayingManager sharedInstance] getCurrentApp]];

	if([PlayingNotificationHelper sharedInstance].sendingTest) {
		[PlayingNotificationHelper sharedInstance].sendingTest = ![PlayingNotificationHelper sharedInstance].sendingTest;
	}
	%orig(bulletin, arg2);
}
%end

static void UpdatePlayingPreferences() {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"me.conorthedev.playing.prefs"];
    [preferences registerDefaults:@{
        @"enabled": @YES,
		@"customText": @""
    }];

    [preferences registerBool:&enabled default:YES forKey:@"enabled"];
	[preferences registerObject:&customText default:@"" forKey:@"customText"];
}

%ctor {
	UpdatePlayingPreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)UpdatePlayingPreferences, CFSTR("me.conorthedev.playing/ReloadPrefs"), NULL, kNilOptions);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SendTestNotification, CFSTR("me.conorthedev.playing/TestNotification"), NULL, kNilOptions);
}

