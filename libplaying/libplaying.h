#import <dlfcn.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkIdentifier;
extern CFStringRef kMRMediaRemoteNowPlayingInfoContentItemIdentifier;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkDataHeight;

@interface BBAction : NSObject
+(id)actionWithLaunchBundleID:(id)arg1;
@end

@interface BBBulletin : NSObject
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, copy) BBAction *defaultAction;
- (id)responseForAction:(id)arg1;
@end

@interface BBResponse : NSObject
@property (nonatomic, copy) NSString *bulletinID;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString *bundleIdentifier;
@end

@interface SBMediaController : NSObject
-(SBApplication *)nowPlayingApplication;
@end

@interface BBServer : NSObject
- (void)_clearSection:(id)arg1;
+ (id)savedSectionInfo;
- (id)_sortedSectionIDs;
- (id)allBulletinIDsForSectionID:(id)arg1;
-(id)_bulletinsForIDs:(id)arg1;
-(id)_allBulletinsForSectionID:(id)arg1 ;
@end

@interface CPNotification : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId;
@end

/**
 * The manager class for 'Playing'
 * Allows extensions to get information about the current song
*/
@interface PlayingManager : NSObject
@property (nonatomic, strong) NSDictionary *currentDictionary;

+ (instancetype)sharedInstance;
+ (instancetype)init;

-(UIImage *)getArtwork;
-(NSString *)getArtworkIdentifier;
-(NSString *)getSongTitle;
-(NSString *)getArtistName;
-(NSString *)getAlbumName;
-(NSString *)getCurrentApp;

-(void)setMetadata:(NSDictionary *)dict;
@end

/**
 * The notification helper class for 'Playing'
 * Allows easier Notification Management
*/
@interface PlayingNotificationHelper : NSObject
NS_ASSUME_NONNULL_END
@property (nonatomic, strong) BBServer *_Nullable bbServer;

NS_ASSUME_NONNULL_BEGIN
+ (instancetype)sharedInstance;
+ (instancetype)init;

-(void)submitNotification:(NSString *)messageFormat;
-(void)submitTestNotification:(NSString *)messageFormat;
-(void)clearNotifications;
NS_ASSUME_NONNULL_END
@end