//
//  SGUploadsTableViewController.h
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGHandlerProtocol <NSObject>

- (void)setCompletionHandler:(void (^)(NSDictionary*, NSError *))handler;

@end

@class SGLibraryUploadController;
@interface SGUploadsTableViewController : UITableViewController

- (void)prepareUploadController:(id<SGHandlerProtocol>)uploadC;

@end
