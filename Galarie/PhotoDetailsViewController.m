//
//  FullScreenViewController.m
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "ActionModalViewController.h"

@interface PhotoDetailsViewController () {
    APObject *_selectedPhoto;
}

@end

@implementation PhotoDetailsViewController

-(void) setPhoto:(APObject*)photoObj {
    _selectedPhoto = [[APObject alloc] initWithTypeName:@"photo"];
    _selectedPhoto = photoObj;
}

-(IBAction) actionButtonTapped {
    [self performSegueWithIdentifier:@"showActionsView" sender:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __block NSString *likeStr = [[NSString alloc] init];
    __block NSString *commentStr = [[NSString alloc] init];
    [APGraphNode applyProjectionGraphQuery:@"photo_details" usingPlaceHolders:nil forObjectsIds:@[_selectedPhoto.objectId] successHandler:^(NSArray *nodes) {
        [_photoName setText:[((APGraphNode*)nodes[0]).object getPropertyWithKey:@"filename"]];
        for(id obj in [((APGraphNode*)nodes[0]).map valueForKey:@"user_likes"]) {
            likeStr = [likeStr stringByAppendingFormat:@"%@ \n",((APUser*)((APGraphNode*)obj).object).username];
        }
        for(id obj in [((APGraphNode*)nodes[0]).map valueForKey:@"user_comment"]) {
            commentStr = [commentStr stringByAppendingFormat:@"%@: %@ \n",((APUser*)((APGraphNode*)obj).object).username, [((APGraphNode*)obj).connection getPropertyWithKey:@"text"]];
        }
        self.likedBy.text = likeStr;
        self.comments.text = commentStr;
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showActionsView"])
    [segue.destinationViewController setPhoto:_selectedPhoto];
}

@end
