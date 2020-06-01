#import "libplaying.h"

void TestNotificationsCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
    [[PlayingNotificationManager sharedInstance] submitTestNotification];
}

extern dispatch_queue_t __BBServerQueue;

@implementation PlayingNotificationManager
+ (instancetype)sharedInstance {
    static PlayingNotificationManager *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayingNotificationManager alloc];
        sharedInstance.manager = [PlayingManager sharedInstance];
        sharedInstance.preferences = [PlayingPreferences sharedInstance];

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), CFBridgingRetain(sharedInstance), &TestNotificationsCallback, (__bridge CFNotificationName)@"me.conorthedev.playing/TestNotification", NULL, 0);
    });
    return sharedInstance;
}

+ (instancetype)init {
    return [PlayingNotificationManager sharedInstance];
}

-(void)submitNotification {  
    NSString *songTitle = [self.manager getSongTitle] ?: @"";
    NSString *songArtist = [self.manager getArtistName] ?: @"Unknown Artist";
    NSString *songAlbum = [self.manager getAlbumName] ?: @"Unknown Album";

    [self clearNotifications];

    // Setup autoclear timer  
    if(self.preferences.interval != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.clearTimer = [NSTimer scheduledTimerWithTimeInterval:self.preferences.interval target:self selector:@selector(clearNotifications) userInfo:nil repeats:NO];
        });
    }

    if (![songTitle isEqualToString:@"Loading..."] && ![songTitle isEqualToString:@""] && ![songArtist isEqualToString:@""] && ![songAlbum isEqualToString:@""]) {
        NSString *bundleID = (self.preferences.asMediaApp) ? (self.manager.currentApp) : (@"me.conorthedev.playing");
        NSString *msg = [NSString stringWithFormat:@"%@ by %@", songTitle, songArtist];
        NSString *title = [NSString stringWithFormat:@"Now Playing"];

        if(![self.preferences.customText isEqualToString:@""]) {
            msg = [self.preferences.customText stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
            msg = [msg stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
            msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
            msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        }

        if(![self.preferences.customTitle isEqualToString:@""]) {
            title = [self.preferences.customTitle stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
            title = [title stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
            title = [title stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
        }

        BBBulletin *bulletin = [[objc_getClass("BBBulletin") alloc] init];
        bulletin.title = title;
        bulletin.message = msg;
        bulletin.sectionID = bundleID;
        bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
        bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
        bulletin.publisherBulletinID = [NSString stringWithFormat:@"me.conorthedev.playing-%@",[[NSProcessInfo processInfo] globallyUniqueString]];
        bulletin.date = [NSDate new];
        bulletin.defaultAction = [objc_getClass("BBAction") actionWithLaunchBundleID:self.manager.currentApp];

        dispatch_sync(__BBServerQueue, ^{
            if(self.bbServer != NULL) {
                [self.bbServer publishBulletin:bulletin destinations:15];
            }
        });       
    }
}

-(void)submitTestNotification {
    NSString *songTitle = @"Title";
    NSString *songArtist = @"Artist";
    NSString *songAlbum = @"Album";
    NSString *msg = [NSString stringWithFormat:@"%@ by %@", songTitle, songArtist];
    NSString *title = [NSString stringWithFormat:@"Now Playing"];
    NSString *bundleID = (self.preferences.asMediaApp) ? (self.manager.currentApp) : (@"me.conorthedev.playing");

    [self clearNotifications];

    if(![self.preferences.customText isEqualToString:@""]) {
        msg = [self.preferences.customText stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
        msg = [msg stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
        msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
        msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }

    if(![self.preferences.customTitle isEqualToString:@""]) {
        title = [self.preferences.customTitle stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
        title = [title stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
        title = [title stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
    }
    
    /*[self saveImage:[self.manager getArtwork]];
    NSBundle *bulletinBoard = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/BulletinBoard.framework"];
    [bulletinBoard load];
    
    BBAttachmentMetadata *attach = [[NSClassFromString(@"BBAttachmentMetadata") alloc] _initWithUUID:[NSUUID UUID] type:1 URL:[NSURL fileURLWithPath:@"/Applications/PlayingApp.app/AppIcon76x76.png"]];*/
    BBBulletin *bulletin = [[objc_getClass("BBBulletin") alloc] init];
    bulletin.title = title;
    bulletin.message = msg;
    bulletin.sectionID = bundleID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = [NSDate new];
    bulletin.defaultAction = [objc_getClass("BBAction") actionWithLaunchBundleID:self.manager.currentApp];
    //bulletin.primaryAttachment = attach;

    dispatch_sync(__BBServerQueue, ^{
        if(self.bbServer != NULL) {
            [self.bbServer publishBulletin:bulletin destinations:15];
        }
    });        
}

-(void)clearNotifications {
    dispatch_sync(__BBServerQueue, ^{
        if(self.bbServer != NULL) {
            NSString *bundleID = (self.preferences.asMediaApp) ? (self.manager.currentApp) : (@"me.conorthedev.playing");
            [self.bbServer _clearSection:bundleID];
        }
	});
}

-(void)saveImage:(UIImage*)image {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = @"/var/mobile/Documents/artwork.jpeg";
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}

@end