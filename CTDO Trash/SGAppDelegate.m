//
//  SGAppDelegate.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGAppDelegate.h"
#import "AFNetworking.h"
#import "SGUploadController.h"
#import "SGLibraryUploadController.h"
#import "SGUploadsTableViewController.h"

SGAppDelegate const *appDelegate;

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    appDelegate = self;
    
    UIColor *blue = UIColorFromHEX(0x1F73FF);
    UIImage *img = [UIImage imageNamed:@"escheresque"];
    
    [[UINavigationBar appearance] setBackgroundImage:img
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
     //UITextAttributeFont:[UIFont fontWithName:@"Verdana" size:18],
                                UITextAttributeTextColor:[UIColor darkTextColor],
                          UITextAttributeTextShadowColor:[UIColor clearColor]}];
    
    [[UITabBar appearance] setBackgroundImage:img];
    [[UITabBar appearance] setSelectedImageTintColor:blue];
    [[UIToolbar appearance] setBackgroundImage:img forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    img = [UIImage imageNamed:@"empty"];
    [[UIBarButtonItem appearance] setBackgroundImage:img
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
     //UITextAttributeFont:[UIFont fontWithName:@"Verdana" size:14],
                                UITextAttributeTextColor:blue,
                          UITextAttributeTextShadowColor:[UIColor clearColor]}
                                                forState:UIControlStateNormal];
    
    
    img = [UIImage imageNamed:@"empty-40"];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    UINavigationController *navC = (UINavigationController *)self.window.rootViewController;
    
    SGUploadsTableViewController *table = (SGUploadsTableViewController *)navC.viewControllers[0];
    SGUploadController *upload = [table.storyboard instantiateViewControllerWithIdentifier:@"SGUploadController"];
    [table prepareUploadController:upload];
    
    
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[url pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    upload.fileName = url.lastPathComponent;
    upload.mimeType = mimeType;
    upload.uploadData = [NSData dataWithContentsOfURL:url];
    
    [navC pushViewController:upload animated:YES];
    
    return YES;
}

@end
