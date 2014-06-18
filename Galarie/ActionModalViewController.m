//
//  ActionModalViewController.m
//  Galarie
//
//  Created by Pratik on 04-03-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "ActionModalViewController.h"
#import "LoginViewController.h"

@interface ActionModalViewController ()<UITextViewDelegate, UIGestureRecognizerDelegate> {
    APObject *selectedPhoto;
    BOOL like;
    NSString *comment;
}

@end

@implementation ActionModalViewController

- (void) setPhoto:(APObject*)photoObj {
    selectedPhoto = [[APObject alloc] initWithTypeName:@"photo"];
    selectedPhoto = photoObj;
}

- (IBAction) likeIconTapped:(UIGestureRecognizer*)sender {
    [self likeButtonTapped:sender];
}

- (IBAction) likeButtonTapped:(id)sender {
    if ([self.likeButton titleColorForState:UIControlStateNormal] == [UIColor whiteColor]) {
        [self.likeButton setTitle:@"Liked" forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.likeIcon setImage:[UIImage imageNamed:@"Liked"]];
     }
    else {
        [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.likeIcon setImage:[UIImage imageNamed:@"Like"]];
    }
}

- (IBAction) doneButtonTapped {
    if ([self.likeButton titleColorForState:UIControlStateNormal] == [UIColor redColor]) {
        APConnection *likesConnection = [[APConnection alloc] initWithRelationType:@"likes"];
        [likesConnection createConnectionWithObjectA:[LoginViewController getCurrentUser] objectB:selectedPhoto labelA:@"user" labelB:@"photo" successHandler:^{
            NSLog(@"Connection created");
        } failureHandler:^(APError *error) {
            NSLog(@"Error: %@",[error description]);
        }];
    }
    if (![[self.commentBox.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        APConnection *commentedConnection = [[APConnection alloc] initWithRelationType:@"commented"];
        [commentedConnection addPropertyWithKey:@"text" value:self.commentBox.text];
        [commentedConnection createConnectionWithObjectA:[LoginViewController getCurrentUser] objectB:selectedPhoto labelA:@"user" labelB:@"photo" successHandler:^{
            NSLog(@"Connection created");
            [self dismissViewControllerAnimated:YES completion:nil];
        } failureHandler:^(APError *error) {
            NSLog(@"Error: %@",[error description]);
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction) cancelButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    comment = [[NSString alloc] init];
    like = NO;
    [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.iconTap = [[UIGestureRecognizer alloc] initWithTarget:self.likeIcon action:@selector(likeIconTapped:)];
    [self.likeIcon addGestureRecognizer:self.iconTap];
}

#pragma mark TextView delegate impementation

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
