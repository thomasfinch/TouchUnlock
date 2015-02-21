%hook SBUIBiometricEventMonitor

- (BOOL)hasEnrolledIdentities {
	return YES;
}

- (void)_reevaluateMatching {
	if ([[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet])
		%orig;
	else if (MSHookIvar<BOOL>(self, "_screenIsOff"))
		[self _stopMatching];
	else
		[self _startMatching];
}

%end

%hook SBLockScreenManager

- (void)unlockUIFromSource:(int)arg1 withOptions:(id)arg2 {
	[[%c(SBUIBiometricEventMonitor) sharedInstance] _stopMatching];
	%orig;
}

%end

@interface TouchUnlockController : NSObject
@end

@implementation TouchUnlockController

-(void)biometricEventMonitor: (id)monitor handleBiometricEvent: (unsigned)event {
	if (event == 2 && ![[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet]) //Event 2 is TouchIDFingerHeld
   		[[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:0 withOptions:nil];
}

-(void)startMonitoringEvents {
	id monitor = [%c(SBUIBiometricEventMonitor) sharedInstance];
	[[%c(BiometricKit) manager] setDelegate:monitor];
	[monitor addObserver:self];
	[monitor _setMatchingEnabled:YES];
	[monitor _startMatching];
}

@end

%ctor {
	TouchUnlockController *unlockController = [[TouchUnlockController alloc] init];
	[unlockController startMonitoringEvents];
}
