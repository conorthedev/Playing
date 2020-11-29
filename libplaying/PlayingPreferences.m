#import "libplaying.h"

void PlayingPreferencesCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
    [[PlayingPreferences sharedInstance] updatePreferences];
}

@implementation PlayingPreferences 
+ (instancetype)sharedInstance {
    static PlayingPreferences *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayingPreferences alloc];
        sharedInstance.preferences = [[HBPreferences alloc] initWithIdentifier:@"dev.hyper.playing.prefs"];
        [sharedInstance updatePreferences];

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), CFBridgingRetain(sharedInstance), &PlayingPreferencesCallback, (__bridge CFNotificationName)@"me.conorthedev.playing/ReloadPrefs", NULL, 0);
    });
    return sharedInstance;
}

+ (instancetype)init {
    return [PlayingPreferences sharedInstance];
}

-(void)updatePreferences {
    [self.preferences registerDefaults:@{
        @"enabled": @YES,
		@"asMediaApp": @NO,
		@"customText": @"",
		@"customTitle": @"",
		@"autoclearInterval": @0,
        @"colouredControls": @YES,
        @"mediaControlsColorOpacity": @0.65
    }];

    [self.preferences registerBool:&_enabled default:YES forKey:@"enabled"];
	[self.preferences registerBool:&_asMediaApp default:NO forKey:@"asMediaApp"];
	[self.preferences registerObject:&_customText default:@"" forKey:@"customText"];
	[self.preferences registerObject:&_customTitle default:@"" forKey:@"customTitle"];
	[self.preferences registerDouble:&_interval default:0 forKey:@"autoclearInterval"];
    [self.preferences registerBool:&_colouredControls default:YES forKey:@"colouredControls"];
    [self.preferences registerDouble:&_mediaControlsColorOpacity default:0.65 forKey:@"mediaControlsColorOpacity"];
}
@end