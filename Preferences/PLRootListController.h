#import <CepheiPrefs/CepheiPrefs.h>
#import <Preferences/PSEditableTableCell.h>
#import <AppList/AppList.h>

@interface PLRootListController : HBRootListController
- (void)testNotification:(id)sender;
- (void)clearBanners:(id)sender;
@end

@interface ReturnableTextCell : PSEditableTableCell
@end