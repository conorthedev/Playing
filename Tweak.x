#import "Tweak.h"

bool shortlookInstalled = false;

static PlayingNotificationManager *notificationManager;
static PlayingManager *manager;
static PlayingPreferences *preferences;
static MediaControlsViewController *currentView;

%group MediaControllerHook
%hook SBMediaController
-(void)_setNowPlayingApplication:(SBApplication*)arg1 {
	%orig;
	manager.currentApp = arg1.bundleIdentifier;
}

-(void)setNowPlayingInfo:(id)arg1 {
	%orig;

	if(preferences.enabled) {
		dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, shortlookInstalled ? (NSEC_PER_SEC * 0.75) : 0);
    	dispatch_after(delay, dispatch_get_main_queue(), ^(void){
			MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {				
				NSString *currentID = @"";
				SBApplication *currentApplication = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];
				
				if(currentApplication) {
					currentID = currentApplication.bundleIdentifier;
				}

				bool showBanner = true;
				if(manager.currentApp && ![manager.currentApp isEqualToString:@""] && currentID && ![currentID isEqualToString:@""]) {
					if ([[preferences.preferences objectForKey:[@"blacklist-" stringByAppendingString:manager.currentApp]] boolValue]) {
						return;
					}

					showBanner = ![[preferences.preferences objectForKey:[@"dontshow-" stringByAppendingString:currentID]] boolValue];
				}
				
				NSMutableDictionary *mutableInformation = [(__bridge NSDictionary *)information mutableCopy];
				[mutableInformation setValue:[NSNumber numberWithBool:showBanner] forKey:@"showBanner"];
				[manager setMetadata:mutableInformation];

				[currentView applyPlaying];
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

%group ColouredControls
%hook MediaControlsViewController

-(void)loadView {
	%orig;
	[self applyPlaying];
}

-(void)viewWillAppear:(BOOL)animated {
    %orig;
	[self applyPlaying];
}

-(void)viewDidDisappear:(BOOL)animated {
	%orig;
	currentView = nil;
}

%new
-(void)applyPlaying {
	MediaControlsViewController *typedSelf = ((MediaControlsViewController *) self);

	if ([preferences colouredControls]) {
		typedSelf.view.superview.layer.cornerRadius = 13;
    	typedSelf.view.superview.layer.masksToBounds = TRUE;

		UIImage *artwork = [manager getArtwork];
		UIColor *backgroundColor = (artwork != nil) ? [artwork getAverageColor] : [UIColor clearColor];
		[UIView animateWithDuration:0.2f animations:^{
   			typedSelf.view.superview.backgroundColor = [backgroundColor colorWithAlphaComponent:[preferences mediaControlsColorOpacity]];
		}];
	} else {
		[UIView animateWithDuration:0.2f animations:^{
   			typedSelf.view.superview.backgroundColor = [UIColor clearColor];
		}];
	}

	currentView = self;
}

%end
%end

void PlayingPreferencesUpdated(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
	if (currentView) {
		[currentView applyPlaying];
	}
}


%ctor {
	notificationManager = [PlayingNotificationManager sharedInstance];
	manager = [PlayingManager sharedInstance];
	preferences = [PlayingPreferences sharedInstance];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &PlayingPreferencesUpdated, (__bridge CFNotificationName)@"me.conorthedev.playing/ReloadPrefs", NULL, 0);

	NSString *shortlookPath = @"/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib";
	if ([[NSFileManager defaultManager] fileExistsAtPath:shortlookPath]){
		shortlookInstalled = true;

		dlopen([shortlookPath UTF8String], RTLD_LAZY);
		%init(ShortLookFixer);
	}
	
	%init(BBServerManager);
	%init(MediaControllerHook);

	NSString *mediaControlsControllerClass = @"SBDashboardMediaControlsViewController";
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
		mediaControlsControllerClass = @"CSMediaControlsViewController";
	}

	%init(ColouredControls, MediaControlsViewController = NSClassFromString(mediaControlsControllerClass));
}