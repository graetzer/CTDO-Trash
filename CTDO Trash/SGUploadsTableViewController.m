//
//  SGUploadsTableViewController.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGUploadsTableViewController.h"
#import "SGImagePickerController.h"
#import "SGAppDelegate.h"

@implementation SGUploadsTableViewController {
    NSMutableArray *_uploads;
    NSDateFormatter *_dateFormatter;
}

- (NSString *)cachePath {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:@"uploads.plist"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"creampaper"]];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _uploads = [[NSMutableArray alloc] initWithContentsOfFile:[self cachePath]];
    if (!_uploads) _uploads = [NSMutableArray arrayWithCapacity:10];
    _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
}

- (void)saveUploads {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_uploads writeToFile:[self cachePath] atomically:YES];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImagePicker"]) {
        SGImagePickerController *up = segue.destinationViewController;
        [self prepareUploadController:up];
    }
}

- (void)prepareUploadController:(id<SGHandlerProtocol>)uploadC {
    void (^handler)(NSDictionary *, NSError *error) = ^(NSDictionary *result, NSError *error){
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fehler", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [_uploads insertObject:result atIndex:0];
        [self.tableView reloadData];
        [self saveUploads];
    };
    
    [uploadC setCompletionHandler:handler];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uploads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *name = _uploads[indexPath.row][@"name"];
    if (name) cell.textLabel.text = name;
    else cell.textLabel.text = _uploads[indexPath.row][@"url"];
    
    NSString *dateString = [_dateFormatter stringFromDate:_uploads[indexPath.row][@"date"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", dateString, _uploads[indexPath.row][@"expires"]];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_uploads removeObjectAtIndex:indexPath.row];
        [self saveUploads];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id obj = _uploads[fromIndexPath.row];
    [_uploads removeObjectAtIndex:fromIndexPath.row];
    [_uploads insertObject:obj atIndex:toIndexPath.row];
    [self saveUploads];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = _uploads[indexPath.row][@"url"];
    NSString *foxbrowserString= [urlString stringByReplacingOccurrencesOfString:@"http://" withString:@"foxbrowser://"];
    
    NSURL *url = [NSURL URLWithString:foxbrowserString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = _uploads[indexPath.row][@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:NULL];
}

@end
