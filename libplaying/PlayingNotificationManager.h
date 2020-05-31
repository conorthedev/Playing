#import "internal/headers.h"
#import "PlayingPreferences.h"

/**
 * The notification helper class for 'Playing'
 * Allows easier Notification Management
*/
@interface PlayingNotificationManager : NSObject
@property (nonatomic, strong) BBServer *bbServer;
@property (nonatomic, strong) NSTimer *clearTimer;
@property (nonatomic, strong) PlayingManager *manager;
@property (nonatomic, strong) PlayingPreferences *preferences;

+ (instancetype)sharedInstance;
+ (instancetype)init;

-(void)submitNotification;
-(void)submitTestNotification;
-(void)clearNotifications;
@end