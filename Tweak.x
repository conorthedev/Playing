#import <Playing/libplaying.h>
#import <Cephei/HBPreferences.h>
#import <MediaRemote/MediaRemote.h>
#import <AppList/AppList.h>

static HBPreferences *preferences = NULL;

BOOL enabled;
BOOL asMediaApp;
NSString *customText = @"";

void SendTestNotification(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
	[[PlayingNotificationHelper sharedInstance] submitTestNotification:customText];
}

%hook SBMediaController

-(void)setNowPlayingInfo:(id)arg1 {
	%orig;
	if(enabled) {
		dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.75);
    	dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
				NSString *bundleID = @"";
				NSString *currentID = @"";
				
				if([self nowPlayingApplication]) {
					bundleID = [self nowPlayingApplication].bundleIdentifier;
				}

				if([[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication]) {
					currentID = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier;
				}

				if(bundleID || ![bundleID isEqualToString:@""]) {
					if(currentID || ![currentID isEqualToString:@""]) {
						if ([[preferences objectForKey:[@"blacklist-" stringByAppendingString:bundleID]] boolValue] || [[preferences objectForKey:[@"dontshow-" stringByAppendingString:currentID]] boolValue]) {
							return;
						}
					}
				}
				
				NSMutableDictionary *dict = [(__bridge NSDictionary *)information mutableCopy];
				[dict setObject:customText forKey:@"customText"];
				[dict setObject:bundleID forKey:@"bundleID"];
				[dict setObject:@(asMediaApp) forKey: @"asMediaApp"];

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
%end

%hook DDUserNotification 
- (NSString *)senderIdentifier {
	NSString *orig = %orig;
	if(!asMediaApp) {
		return %orig;
	}

	if([orig isEqualToString:[[PlayingManager sharedInstance] getCurrentApp]]) {
		return @"me.conorthedev.playing";
	} else {
		return orig;
	}
}
%end

static void UpdatePlayingPreferences() {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"dev.hyper.playing.prefs"];
    [preferences registerDefaults:@{
        @"enabled": @YES,
		@"asMediaApp": @NO,
		@"customText": @""
    }];

    [preferences registerBool:&enabled default:YES forKey:@"enabled"];
	[preferences registerBool:&asMediaApp default:NO forKey:@"asMediaApp"];
	[preferences registerObject:&customText default:@"" forKey:@"customText"];
}

%ctor {
	NSString *shortlookPath = @"/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib";
	if ([[NSFileManager defaultManager] fileExistsAtPath:shortlookPath]){
		dlopen("/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib", RTLD_LAZY);
	}

	UpdatePlayingPreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)UpdatePlayingPreferences, CFSTR("me.conorthedev.playing/ReloadPrefs"), NULL, kNilOptions);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SendTestNotification, CFSTR("me.conorthedev.playing/TestNotification"), NULL, kNilOptions);
	
	%init;
}

