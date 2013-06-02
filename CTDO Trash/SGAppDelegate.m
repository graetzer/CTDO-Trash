//
//  SGAppDelegate.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGAppDelegate.h"
#import "AFNetworking.h"

SGAppDelegate const *appDelegate;

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    appDelegate = self;
    
    UIImage *img = [UIImage imageNamed:@"escheresque_ste"];
    
    [[UINavigationBar appearance] setBackgroundImage:img
                                       forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setBackgroundImage:img];
    [[UIToolbar appearance] setBackgroundImage:img forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    img = [[UIImage imageNamed:@"button-small-default"]
           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:img
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    img = [[UIImage imageNamed:@"button-back"]
           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:img
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://trash.ctdo.de"]];
    [self.httpClient setDefaultHeader:@"User-Agent"
                                value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0"];
    
    return YES;
}

//- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
//    return YES;
//}
//
//- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
//    return YES;
//}

// Version 2
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    
//    
//    
//    return YES;
//}

@end
