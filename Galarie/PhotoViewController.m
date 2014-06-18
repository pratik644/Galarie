//
//  PhotoViewController.m
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoDetailsViewController.h"
#import <Appacitive/AppacitiveSDK.h>

@implementation PhotoViewController {
    NSMutableArray *_photoList;
    NSInteger _index;
    NSString *_selectedAlbumId;
    NSMutableArray *_images;
}

-(void) setAlbumId:(NSString*)albumId {
    if(_selectedAlbumId == nil)
        _selectedAlbumId = [[NSString alloc] init];
    _selectedAlbumId = albumId;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setTitle:@"photos"];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arabesque"]];
    UIView *alphaLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [alphaLayer setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.600]];
    [background addSubview:alphaLayer];
    [self.tableView setBackgroundView:background];
    
    _images = [[NSMutableArray alloc] init];
    _photoList = [[NSMutableArray alloc] init];

    [APConnections fetchObjectsConnectedToObjectOfType:@"album" withObjectId:_selectedAlbumId withRelationType:@"belongs_to" fetchConnections:NO successHandler:^(NSArray *objects) {
        for (APGraphNode *node in objects) {
            [_photoList addObject:node.object];
            [_images addObject:[NSNull null]];
        }
        [self.tableView reloadData];
        
        for (int i=0; i<_photoList.count; i++) {
            [APFile downloadFileWithName:[_photoList[i] getPropertyWithKey:@"filename"] urlExpiresAfter:@-1 successHandler:^(NSData *data) {
                if(data != nil) {
                    [_images setObject:[UIImage imageWithData:data] atIndexedSubscript:i];
                    [self.tableView reloadData];
                }
            }];
        }

    } failureHandler:^(APError *error) {
        NSLog(@"ERROR: %@",error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingIndicator setFrame:CGRectMake(((320-loadingIndicator.bounds.size.width)/2), ((215-loadingIndicator.bounds.size.height)/2), loadingIndicator.bounds.size.width,loadingIndicator.bounds.size.height)];
        [loadingIndicator setTag:100];
        
        UIImageView *cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        [cellImage setClipsToBounds:YES];
        [cellImage setTag:200];
        [cellImage setContentMode:UIViewContentModeScaleAspectFill];
        
        [cell addSubview:loadingIndicator];
        [loadingIndicator startAnimating];
        [cell addSubview:cellImage];
        
    } else {
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
        imageView.image = nil;
        [imageView setNeedsDisplay];
    }
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:100];
    [activityIndicator startAnimating];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if([_images objectAtIndex:indexPath.row] != [NSNull null])
        [imageView setImage:[_images objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _index = indexPath.row;
    [self performSegueWithIdentifier:@"details" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual: @"details"]) {
        [segue.destinationViewController setPhoto:_photoList[_index]];
    }
}

@end
