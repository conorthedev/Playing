#import "libplaying.h"

extern dispatch_queue_t __BBServerQueue;

@implementation PlayingManager
+ (instancetype)sharedInstance {
    static PlayingManager *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayingManager alloc];
    });
    return sharedInstance;
}

+ (instancetype)init {
    return [PlayingManager sharedInstance];
}

-(UIImage *)getArtwork {
    if(_currentDictionary == NULL || [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] == NULL) {
        return NULL;
    }

    return [UIImage imageWithData:[_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]];
}

-(NSString *)getArtworkIdentifier {
    if(_currentDictionary == NULL) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkIdentifier];
}

-(NSString *)getSongTitle {
    if(_currentDictionary == NULL) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
}

-(NSString *)getArtistName {
    if(_currentDictionary == NULL) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
}

-(NSString *)getAlbumName {
    if(_currentDictionary == NULL) {
        return @"";
    }

    return [_currentDictionary objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
}

-(void)setMetadata:(NSDictionary *)dict {
    NSString *newTitle = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];

    if(_currentDictionary == NULL || (![newTitle isEqualToString:@""] && ![[self getSongTitle] isEqualToString:newTitle])) {
        _currentDictionary = dict;
        [[PlayingNotificationHelper sharedInstance] submitNotification:_currentDictionary[@"customText"]];
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
    NSString *songArtist = [[PlayingManager sharedInstance] getArtistName];
    NSString *songAlbum = [[PlayingManager sharedInstance] getAlbumName];

    if (![songTitle isEqualToString:@""] && ![songArtist isEqualToString:@""] && ![songAlbum isEqualToString:@""]) {
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