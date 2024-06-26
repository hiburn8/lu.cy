// fan.cy
//
// Credit goes where it's due :)
//
// Adam Bell, 2014

// Don't want to inject these scripts multiple times :D
// I know this makes no sense, but no u
if (typeof fancySetup === 'undefined'){

    @import com.saurik.substrate.MS;

    // kennytm / iphonedevwiki.net (http://networkpx.googlecode.com/svn/etc/std.cy, http://iphonedevwiki.net/index.php/Cycript_Tricks)
    NSLog_ = dlsym(RTLD_DEFAULT, "NSLog");
    NSLog = function() { var types = 'v', args = [], count = arguments.length; for (var i = 0; i != count; ++i) { types += '@'; args.push(arguments[i]); } new Functor(NSLog_, types).apply(null, args); };

    function CGPointMake(x, y) { return {x:x, y:y}; }
    function CGSizeMake(w, h) { return {width:w, height:h}; }
    function CGRectMake(x, y, w, h) { return {origin:CGPointMake(x,y), size:CGSizeMake(w, h)}; }
    function NSMakeRange(loc, len) { return {location:loc, length:len}; }

    function CGRectOffset(rect, dx, dy) { var copy = rect; copy.origin.x += dx; copy.origin.y += dy; return copy; }
    function CGRectInset(rect, dx, dy) { var copy = CGRectOffset(rect, dx, dy); copy.size.width -= (dx * 2.0); copy.size.height -= (dy * 2.0); return copy; }

    CFRangeMake = NSMakeRange;

    CGPointZero = CGPointMake(0,0);
    CGSizeZero = CGSizeMake(0,0);
    CGRectZero = CGRectMake(0,0,0,0);

    CGRect = new Type("{CGRect}");
    CGSize = new Type("{CGSize}");
    CGPoint = new Type("{CGPoint}");
    NSRange = new Type("{NSRange}");
    CFRange = new Type("{CFRange}");
    CGAffineTransform = new Type("{CGAffineTransform}");
    CATransform3D = new Type("{CATransform3D}");
    UIEdgeInsets = new Type("{UIEdgeInsets}");

    function include(fn) {
      var t = [new NSTask init]; [t setLaunchPath:@"/usr/bin/cycript"]; [t setArguments:["-c", fn]];
      var p = [NSPipe pipe]; [t setStandardOutput:p]; [t launch]; [t waitUntilExit];  [t release];
      var s = [new NSString initWithData:[[p fileHandleForReading] readDataToEndOfFile] encoding:4];
      var r = this.eval(s.toString()); [s release]; return r;
    }

    // Me
    CGAffineTransformIdentity = CGAffineTransformMakeScale(1,1);
    CATransform3DIdentity = CATransform3DMakeScale(1,1,1);

    UIDeviceOrientationUnknown = 0;
    UIDeviceOrientationPortrait = 1;
    UIDeviceOrientationPortraitUpsideDown = 2;
    UIDeviceOrientationLandscapeLeft = 3;
    UIDeviceOrientationLandscapeRight = 4;
    UIDeviceOrientationFaceUp = 5;
    UIDeviceOrientationFaceDown = 6;

    UIInterfaceOrientationPortrait = UIDeviceOrientationPortrait;
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown;
    UIInterfaceOrientationLandscapeLeft = UIDeviceOrientationLandscapeRight;
    UIInterfaceOrientationLandscapeRight = UIDeviceOrientationLandscapeLeft;

    function methods(className, methodToSearchFor) {
        var methods = new Array();
        var messages = className.messages;
        for (key in messages) {
            if (arguments.length < 2 || key.match(methodToSearchFor)) {
                methods.push(key);
            }
        }

        methods = methods.sort();

        var formattedMethods = "";
        var c = methods.length;
        for (var i = 0; i < c; i++) {
            formattedMethods += methods[i] + "\n";
        }
        return formattedMethods;
    }

    // Tags are probably not the nicest solutions, but objc_allocateClassPair explodes in cycript for some reason :(
    function unhighlight(view) {
        var tag = 0x9001;
        [[view viewWithTag:tag] removeFromSuperview];

        [view setNeedsDisplay];
    }

    function highlight(view) {
        if (![view isKindOfClass:[UIView class]])
            return;

        var tag = 0x9001; // IT'S OVER 9000!@#$!

        unhighlight(view);

        var highlight = [[UIView alloc] initWithFrame:view.bounds];
        highlight.backgroundColor = [UIColor clearColor];
        highlight.layer.borderWidth = 10;
        highlight.layer.borderColor = [[UIColor colorWithRed:0.37 green:0.76 blue:1.00 alpha:1.00] CGColor];
        highlight.tag = tag;
        highlight.clipsToBounds = NO;
        [view addSubview:highlight];

        [view setNeedsDisplay];
    }

    UIView.prototype.highlight = function() {
        highlight(this);
    }

    UIView.prototype.unhighlight = function() {
        unhighlight(this);
    }

    function setX(view, x) {
        var frame = view.frame;
        frame.origin.x = x;
    }

    function setY(view, y) {
        var frame = view.frame;
        frame.origin.y = y;
    }

    function setWidth(view, width) {
        var frame = view.frame;
        frame.size.width = width;
    }

    function setHeight(view, height) {
        var frame = view.frame;
        frame.size.height = height;
    }

    function showview(view){ UIApp.keyWindow.rootViewController = [[view alloc] init]}

//pretty-much everything below here is from ThatPentestGuy @HBRN8

    function alert(message, title) {
        
        if (typeof message === 'undefined'){ message = "alert";}
        else {message = message.toString();}
        if (typeof title === 'undefined'){ title = "Cycript";}
        else {title = title.toString();}

        var alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:"OK" otherButtonTitles:nil];
        [alert show];

        return alert;
    }

    function help(){
    var docs = ['alert(title, message)',
    '\nmethods(class)',
    '\nhighlight(view) view.highlight()',
    '\nunhighlight(view) view.unhighlight()',
    '\nsetX(x, view) setY(y, view)',
    '\nsetWidth(width, view)',
    '\nsetHeight(height, view)',
    '\nreveal(path)',
    '\nflex(path)']
    alert(docs, "How to fan.cy");
    }

    function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
            break;
        }
    }
    }

    // unlock("1234", "s") will run silently and return nothing
    function unlock(passcode, mode){
    sucess = [[SBLockScreenManager sharedInstance] attemptUnlockWithPasscode:passcode];
    if (typeof mode === 'undefined'){
    return sucess;
    }
    else {
        mode = mode.toString();
        if (mode == "s"){
        }
    }
    }

    // returns nothing. bruteforces passcode as fast as possible.

    function forceunlock(tick){

    if (typeof tick === 'undefined'){var ti = 500;}
    else {var ti = tick/2;}

    for (n=0; n<=9999; n++){
    guess = n.toString();

    if (guess < 10){
    guess = "000".concat(guess);
    }
    if (guess > 9 && guess <100){
    guess = "00".concat(guess);
    }
    if (guess > 99 && guess <1000){
    guess = "0".concat(guess);
    }
    var status = unlock(guess);
    sleep(ti);
    if (status == 1){
        n=10000;
        return guess;
    }
    else{
        sleep(ti);
    }
    }
    }


    function flex(path) {
        if (typeof path !== 'undefined'){ path = path.toString();}
        else {
             if ([UIDevice currentDevice].model.toLowerCase().indexOf("simulator") == -1){
                var path = "/Library/MobileSubstrate/DynamicLibraries/";}
            else
            {var path = "/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/";}     
        }
        
        if (dlopen(path + "FLEXDylib.dylib", RTLD_NOW) === null){
            alert("Error", "failed to load FLEX");
        }
        else {
            [[FLEXManager sharedManager] showExplorer];
            alert("Success", "FLEX library loaded");
        }
    }

    function reveal(path) {
        if (typeof path !== 'undefined'){ path = path.toString();}
        else {
            if ([UIDevice currentDevice].model.toLowerCase().indexOf("simulator") == -1){
                var path = "/Library/MobileSubstrate/DynamicLibraries/";}
            else
            {var path = "/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/";}         
        }
        
        if (dlopen(path + "libReveal.dylib", RTLD_NOW) === null){
            alert("Error", "failed to load revealApp");
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
            alert("Success", "revealApp library loaded");
        }
    }

}

fancySetup = 'Go Go Gadget Fancy';

// Disable printing above message
function cls() {}
cls();
