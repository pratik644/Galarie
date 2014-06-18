//
//  ActionModalViewController.h
//  Galarie
//
//  Created by Pratik on 04-03-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appacitive/AppacitiveSDK.h>

@interface ActionModalViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *commentBox;
@property (strong, nonatomic) IBOutlet UIImageView *likeIcon;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIGestureRecognizer *iconTap;

- (void) setPhoto:(APObject*)photoObj;
- (IBAction) likeButtonTapped:(id)sender;
- (IBAction) likeIconTapped:(UIGestureRecognizer*)sender;
- (IBAction) doneButtonTapped;
- (IBAction) cancelButtonTapped;

@end
