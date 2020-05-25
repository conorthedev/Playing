#import "ShortLook-API.h"
#import <Playing/libplaying.h>

@interface PlayingContactPhotoProvider : NSObject <DDNotificationContactPhotoProviding>
- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification;
@end