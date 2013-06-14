//
//  SGUploadsTableViewController.h
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGUploadController;
@interface SGUploadsTableViewController : UITableViewController

- (void)prepareUploadController:(SGUploadController *)uploadC;

@end
