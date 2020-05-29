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

-(void)setMetadata:(NSDictionary *)dict {
    NSString *newTitle = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];

    if([_currentDictionary count] == 0 || (![newTitle isEqualToString:@""] && ![[self getSongTitle] isEqualToString:newTitle])) {
        _currentDictionary = dict;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[PlayingNotificationHelper sharedInstance] submitNotification:dict[@"customText"]];
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

-(void)submitNotification:(NSString *)messageFormat {
    [self clearNotifications];

    NSString *songTitle = [[PlayingManager sharedInstance] getSongTitle];
    NSString *songArtist = [[PlayingManager sharedInstance] getArtistName] ?: @"Unknown Artist";
    NSString *songAlbum = [[PlayingManager sharedInstance] getAlbumName] ?: @"Unknown Album";
    if(songTitle == NULL) {
        return;
    }

    if (![songTitle isEqualToString:@""] && ![songArtist isEqualToString:@""] && ![songAlbum isEqualToString:@""]) {
        void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);
        if (handle != NULL) {
            NSString *msg = [NSString stringWithFormat:@"%@ by %@ in %@", songTitle, songArtist, songAlbum];
            if(![messageFormat isEqualToString:@""]) {
                msg = [messageFormat stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
                msg = [msg stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
                msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
                msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            }

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wnonnull"
            
            [objc_getClass("CPNotification") showAlertWithTitle:@"Now Playing"
                            message:msg
                            userInfo:@{@"" : @""}
                            badgeCount:0
                            soundName:NULL
                            delay:0.00
                            repeats:NO
                            bundleId:@"dev.hyper.playing"];   
            
            #pragma clang diagnostic pop                               
            dlclose(handle);
        }
    }
}

-(void)submitTestNotification:(NSString *)messageFormat {
    [self clearNotifications];

    NSString *songTitle = @"Title";
    NSString *songArtist = @"Artist";
    NSString *songAlbum = @"Album";

    void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);
    if (handle != NULL) {    
        NSString *msg = [NSString stringWithFormat:@"%@ by %@ in %@", songTitle, songArtist, songAlbum];
        if(![messageFormat isEqualToString:@""]) {
            msg = [messageFormat stringByReplacingOccurrencesOfString:@"@a" withString:songArtist];
            msg = [msg stringByReplacingOccurrencesOfString:@"@t" withString:songTitle];
            msg = [msg stringByReplacingOccurrencesOfString:@"@al" withString:songAlbum];
            msg = [msg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        }

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wnonnull"
        
        [objc_getClass("CPNotification") showAlertWithTitle:@"Now Playing"
                        message:msg
                        userInfo:@{@"" : @""}
                        badgeCount:0
                        soundName:NULL
                        delay:0.00
                        repeats:NO
                        bundleId:@"dev.hyper.playing"];   
        
        #pragma clang diagnostic pop                               
        dlclose(handle);
    }
}

-(void)clearNotifications {
    dispatch_sync(__BBServerQueue, ^{
        if(self.bbServer != NULL) {
            [self.bbServer _clearSection:@"dev.hyper.playing"];
        }
	});
}
@end