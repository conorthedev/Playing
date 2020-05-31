#import "libplaying.h"

extern dispatch_queue_t __BBServerQueue;

@implementation PlayingManager
+ (instancetype)sharedInstance {
    static PlayingManager *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayingManager alloc];
        sharedInstance.currentDictionary = [NSDictionary new];
    });
    return sharedInstance;
}

+ (instancetype)init {
    return [PlayingManager sharedInstance];
}

-(UIImage *)getArtwork {
    if([_currentDictionary count] == 0 || [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] == NULL) {
        return NULL;
    }

    return [UIImage imageWithData:[_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]];
}

-(NSString *)getArtworkIdentifier {
    if([_currentDictionary count] == 0) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkIdentifier];
}

-(NSString *)getSongTitle {
    if([_currentDictionary count] == 0) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
}

-(NSString *)getArtistName {
    if([_currentDictionary count] == 0) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
}

-(NSString *)getAlbumName {
    if([_currentDictionary count] == 0) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
}

-(NSString *)getCurrentApp {
    if([_currentDictionary count] == 0) {
        return @"";
    }

    return _currentDictionary[@"bundleID"];
}

-(void)setMetadata:(NSDictionary *)dict {
    NSString *newTitle = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];

    if([_currentDictionary count] == 0 || (![newTitle isEqualToString:@""] && ![[self getSongTitle] isEqualToString:newTitle])) {
        _currentDictionary = dict;
        self.asMediaApp = [_currentDictionary[@"asMediaApp"] boolValue];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[PlayingNotificationHelper sharedInstance] submitNotification:dict[@"customText"] titleFormat:dict[@"customTitle"]];
        });
    }
}
@end

@implementation PlayingNotificationHelper
+ (instancetype)sharedInstance {
    static PlayingNotificationHelper *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayingNotificationHelper alloc];
    });
    return sharedInstance;
}

+ (instancetype)init {
    return [PlayingNotificationHelper sharedInstance];
}

-(void)submitNotification:(NSString *)messageFormat titleFormat:(NSString *)titleFormat {
    if(self.clearTimer) {
        [self.clearTimer invalidate];
    }
    
    if(self.interval != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.clearTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(clearNotifications) userInfo:nil repeats:NO];
        });
    }

    [self clearNotifications];

    PlayingManager *manager = [PlayingManager sharedInstance];
    NSString *songTitle = [manager getSongTitle] ?: @"";
    NSString *songArtist = [manager getArtistName] ?: @"Unknown Artist";
    NSString *songAlbum = [manager getAlbumName] ?: @"Unknown Album";

    if (![songTitle isEqualToString:@"Loading..."] && ![songTitle isEqualToString:@""] && ![songArtist isEqualToString:@""] && ![songAlbum isEqualToString:@""]) {
        BBBulletin *bulletin = [[objc_getClass("BBBulletin") alloc] init];
        NSString *bundleID = (manager.asMediaApp) ? ([manager getCurrentApp]) : (@"me.conorthedev.playing");
        NSString *msg = [NSString stringWithFormat:@"%@ by %@", songTitle, songArtist];
        NSString *title = [NSString stringWithFormat:@"Now Playing"];

        if(![messageFormat isEqualToString:@""]) {
            msg = [messageFormat stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
            msg = [msg stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
            msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
            msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        }

        if(![titleFormat isEqualToString:@""]) {
            title = [titleFormat stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
            title = [titleFormat stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
            title = [titleFormat stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
        }

        bulletin.title = title;
        bulletin.message = msg;
        bulletin.sectionID = bundleID;
        bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
        bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
        bulletin.publisherBulletinID = [NSString stringWithFormat:@"me.conorthedev.playing-%@",[[NSProcessInfo processInfo] globallyUniqueString]];
        bulletin.date = [NSDate new];
        bulletin.defaultAction = [objc_getClass("BBAction") actionWithLaunchBundleID:bundleID];

        dispatch_sync(__BBServerQueue, ^{
            if(self.bbServer != NULL) {
                [self.bbServer publishBulletin:bulletin destinations:15];
            }
        });       
    }
}

-(void)submitTestNotification:(NSString *)messageFormat titleFormat:(NSString *)titleFormat {
    [self clearNotifications];

    NSString *songTitle = @"Title";
    NSString *songArtist = @"Artist";
    NSString *songAlbum = @"Album";

    BBBulletin *bulletin = [[objc_getClass("BBBulletin") alloc] init];
    NSString *msg = [NSString stringWithFormat:@"%@ by %@", songTitle, songArtist];
    NSString *title = [NSString stringWithFormat:@"Now Playing"];

    if(![messageFormat isEqualToString:@""]) {
        msg = [messageFormat stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
        msg = [msg stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
        msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
        msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }

    if(![titleFormat isEqualToString:@""]) {
        title = [titleFormat stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
        title = [titleFormat stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
        title = [titleFormat stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
    }

    bulletin.title = title;
    bulletin.message = msg;
    bulletin.sectionID = @"me.conorthedev.playing";
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = [NSDate new];
    bulletin.defaultAction = [objc_getClass("BBAction") actionWithLaunchBundleID:@"me.conorthedev.playing"];

    dispatch_sync(__BBServerQueue, ^{
        if(self.bbServer != NULL) {
            [self.bbServer publishBulletin:bulletin destinations:15];
        }
    });        
}

-(void)clearNotifications {
    dispatch_sync(__BBServerQueue, ^{
        if(self.bbServer != NULL) {
            PlayingManager *manager = [PlayingManager sharedInstance];
            NSString *bundleID = (manager.asMediaApp) ? ([manager getCurrentApp]) : (@"me.conorthedev.playing");
            [self.bbServer _clearSection:bundleID];
        }
	});
}

@end