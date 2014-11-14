%hook SBUIBiometricEventMonitor

//If either of these methods are enabled, they prevent touchID events from being sent to
//the touch unlock controller while the device is locked and a passcode isn't enabled.
//So, we make them do nothing if the device doesn't have a passcode, so this tweak can work.
- (void)noteScreenDidTurnOff {
    if ([[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet])
        %orig;
}
- (void)noteScreenWillTurnOff {
    if ([[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet])
        %orig;
}

%end

@interface TouchUnlockController : NSObject
@end

@implementation TouchUnlockController

-(void)biometricEventMonitor: (id)monitor handleBiometricEvent: (unsigned)event
{
   // NSLog(@"TOUCHUNLOCK DELEGATE GOT BIOMETRIC EVENT: %u",event);
   if (event == 2 && ![[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet]) //Event 2 is TouchIDFingerHeld
        [[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:0 withOptions:nil];
}

-(void)startMonitoringEvents
{
	id monitor = [%c(SBUIBiometricEventMonitor) sharedInstance];
	[[%c(BiometricKit) manager] setDelegate:monitor];
	[monitor addObserver:self];
	[monitor _setMatchingEnabled:YES];
	[monitor _startMatching];
}

@end

%ctor
{
   TouchUnlockController *unlockController = [[TouchUnlockController alloc] init];
   [unlockController startMonitoringEvents];
}
