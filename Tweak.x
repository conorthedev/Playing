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
}