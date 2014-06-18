//
//  AlbumListViewController.m
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "AlbumListViewController.h"
#import "PhotoViewController.h"
#import "UploadModalViewController.h"
#import <Appacitive/AppacitiveSDK.h>

@interface AlbumListViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate> {
    UIImage *_imageToUpload;
    NSInteger _index;
    NSMutableArray *_albums;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation AlbumListViewController

- (IBAction)cameraButtonTapped {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Looks like your device does not have a camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _imageToUpload = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        UploadModalViewController *uploadViewController = [[UploadModalViewController alloc] init];
        [uploadViewController setImage:_imageToUpload];
        [uploadViewController setAlbumList:_albums];
        [self performSegueWithIdentifier:@"showUploadPane" sender:self];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _albums = [[NSMutableArray alloc]init];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arabesque"]];
    UIView *alphaLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [alphaLayer setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.600]];
    [background addSubview:alphaLayer];
    [self.tableView setBackgroundView:background];
    
    [APObject searchAllObjectsWithTypeName:@"album" successHandler:^(NSArray *objects, NSInteger pageNumber, NSInteger pageSize, NSInteger totalRecords) {
        for (APObject *obj in objects)
        {
            [_albums addObject:obj];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - TableView DataSource and Delegate implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [[_albums objectAtIndex:indexPath.row] getPropertyWithKey:@"name"];
    cell.accessibilityValue = ((APObject*)[_albums objectAtIndex:indexPath.row]).objectId;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _index = indexPath.row;
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showUploadPane"]) {
        [segue.destinationViewController setAlbumList:_albums];
        [segue.destinationViewController setImage:_imageToUpload];
    }
    if([[segue identifier] isEqualToString:@"showDetails"]) {
        [segue.destinationViewController setAlbumId:((APObject*)_albums[_index]).objectId];
    }
}

@end
