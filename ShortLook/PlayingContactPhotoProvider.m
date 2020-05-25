#import "PlayingContactPhotoProvider.h"

@implementation PlayingContactPhotoProvider

- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
    NSLog(@"HyperDebug: contactPhotoPromiseOfferForNotification: %@", notification);

    PlayingManager *playingManager = [PlayingManager sharedInstance];
    NSString *identifier = [playingManager getArtworkIdentifier];
    UIImage *image = [playingManager getArtwork];

    NSLog(@"HyperDebug: id: %@ | image: %@", identifier, image);

    if([identifier isEqualToString:@""] || image == NULL) {
        return NULL;
    }

	return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:identifier image:image];
}

@end