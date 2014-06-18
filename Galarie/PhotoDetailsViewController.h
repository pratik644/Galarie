//
//  FullScreenViewController.h
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import <Appacitive/AppacitiveSDK.h>

@interface PhotoDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *photoName;
@property (strong, nonatomic) IBOutlet UITextView *likedBy;
@property (strong, nonatomic) IBOutlet UITextView *comments;

-(void) setPhoto:(APObject*)photoObj;
-(IBAction) actionButtonTapped;

@end
