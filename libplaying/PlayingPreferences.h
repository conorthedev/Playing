#import <Cephei/HBPreferences.h>

@interface PlayingPreferences : NSObject
+ (instancetype)sharedInstance;
+ (instancetype)init;

@property (nonatomic, strong) HBPreferences *preferences;

@property (nonatomic) bool enabled;
@property (nonatomic) bool asMediaApp;
@property (nonatomic) double interval;
@property (nonatomic, strong) NSString *customText;
@property (nonatomic, strong) NSString *customTitle;
@property (nonatomic) bool colouredControls;
@property (nonatomic) double mediaControlsColorOpacity;

-(void)updatePreferences;
@end