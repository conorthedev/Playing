#import "PlayingContactPhotoProvider.h"

@implementation PlayingContactPhotoProvider

- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
    PlayingManager *playingManager = [PlayingManager sharedInstance];
    
    NSString *identifier = [playingManager getArtworkIdentifier];
    UIImage *image = [playingManager getArtwork];

    if([identifier isEqualToString:@""] || image == NULL) {
        return NULL;
    }

	return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:identifier image:image];
}

@end
