/**
 * The manager class for 'Playing'
 * Allows extensions to get information about the current song
*/
@interface PlayingManager : NSObject
@property (nonatomic, strong) NSDictionary *currentDictionary;
@property (nonatomic, strong) NSString *currentApp;

+ (instancetype)sharedInstance;
+ (instancetype)init;

-(UIImage *)getArtwork;
-(NSString *)getArtworkIdentifier;
-(NSString *)getSongTitle;
-(NSString *)getArtistName;
-(NSString *)getAlbumName;

-(void)setMetadata:(NSDictionary *)dict;
@end
