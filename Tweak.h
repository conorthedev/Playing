#include <UIKit/UIKit.h>

#import <Playing/libplaying.h>
#import <AppList/AppList.h>
#import <MediaRemote/MediaRemote.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MediaControlsViewController : UIViewController
-(void)applyPlaying;
@end

@interface UIImage (Playing)
- (UIColor *)getAverageColor;
@end
