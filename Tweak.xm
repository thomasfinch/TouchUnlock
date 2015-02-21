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

@interface TouchUnlockController : NSObject
@end

@implementation TouchUnlockController

-(void)biometricEventMonitor: (id)monitor handleBiometricEvent: (unsigned)event {
   // NSLog(@"TOUCHUNLOCK DELEGATE GOT BIOMETRIC EVENT: %u",event);
   if (event == 2 && ![[%c(SBDeviceLockController) sharedController] deviceHasPasscodeSet]) { //Event 2 is TouchIDFingerHeld
   		[[%c(SBUIBiometricEventMonitor) sharedInstance] _stopMatching];
        [[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:0 withOptions:nil];
    }
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
