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

-(bool)shouldShowBanner {
    if([_currentDictionary count] == 0) {
        return true;
    }

    return [[_currentDictionary objectForKey:@"showBanner"] boolValue];
}

-(void)setMetadata:(NSDictionary *)dict {
    NSString *newTitle = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];

    if([_currentDictionary count] == 0 || (![newTitle isEqualToString:@""] && ![[self getSongTitle] isEqualToString:newTitle])) {
        _currentDictionary = dict;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[PlayingNotificationManager sharedInstance] submitNotification];
        });
    }
}
@end