#import "PlayingContactPhotoProvider.h"

@implementation PlayingContactPhotoProvider

- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
    PlayingManager *playingManager = [PlayingManager sharedInstance];
    
    NSString *identifier = [playingManager getArtworkIdentifier];
    UIImage *image = [playingManager getArtwork];

    if([identifier isEqualToString:@""] || image == NULL) {
        return NULL;
    }

	DDNotificationContactPhotoPromiseOffer* promise = [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:identifier image:image];
    promise.titleOverride = [playingManager getSongTitle];
    promise.subtitleOverride = [playingManager getArtistName] ?: @"Unknown Artist";
    promise.bodyOverride = [playingManager getAlbumName] ?: @"Unknown Album";

    return promise;
}

@end
