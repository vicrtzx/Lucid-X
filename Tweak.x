#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface BHTManager : NSObject
+ (void)cleanCache;
@end

static void registerLucidDefaults() {
    NSDictionary *lucidDefaults = @{
        @"hide_promoted": @YES,                  // 100% ad-free (blocks promoted tweets & video ads)
        @"hide_topics": @YES,                    // No topic suggestions
        @"hide_who_to_follow": @YES,             // No follow suggestion cards
        @"hide_topics_to_follow": @YES,          // No topics to follow
        @"hide_premium_offer": @YES,             // No Twitter Blue / Premium upgrade nags
        @"hide_trend_videos": @YES,              // No autoplay trend videos
        @"strip_tracking_params": @YES,          // Strip ?s=20&t=... spy parameters from links
        @"dw_v": @YES,                           // Download media enabled
        @"direct_save": @YES,                    // 1-tap direct save to Camera Roll
        @"autoHighestLoad": @YES,                // Load media in crisp resolution
        @"hide_grok_analyze": @YES,              // Hide Grok AI buttons
        @"disable_xchat": @YES,                  // Disable xchat background polling
        @"disableArticles": @YES,                // Disable articles bloat
        @"disableHighlights": @YES,              // Disable highlights bloat
        @"openInBrowser": @YES,                  // Open links in Safari natively for speed
        @"no_focus_lost": @YES,                  // Don't lose place in thread
        @"tap_to_pause": @YES,                   // 2-finger tap to pause
        @"block_screenshot_detection": @YES      // DM screenshot privacy
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:lucidDefaults];
}

static void performAsyncCacheClean() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        Class bhtManager = objc_getClass("BHTManager");
        if (bhtManager && [bhtManager respondsToSelector:@selector(cleanCache)]) {
            [bhtManager cleanCache];
        }
    });
}

%hook UIApplication
- (void)_applicationDidFinishLaunchingWithOptions:(id)arg1 {
    %orig;
    registerLucidDefaults();
    performAsyncCacheClean();
}
%end

%ctor {
    registerLucidDefaults();
    
    // Register background cleaner notification
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        performAsyncCacheClean();
    }];
    
    %init;
}
