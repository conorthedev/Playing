#include "PLRootListController.h"

@implementation PLRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)testNotification:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.conorthedev.playing/TestNotification", NULL, NULL, TRUE);
}

- (void)clearBanners:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.conorthedev.playing/ClearBanners", NULL, NULL, TRUE);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {        
    [textField resignFirstResponder];
    return YES;
}

@end

@implementation ReturnableTextCell
-(BOOL)textFieldShouldReturn:(id)arg1 {
	return 1;
}
@end