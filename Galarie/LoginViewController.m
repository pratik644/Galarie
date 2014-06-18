//
//  ViewController.m
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

static APUser *_currentUser;

+ (APUser*) getCurrentUser {
    return _currentUser;
}

- (IBAction)login {
    if(_username.text != nil && _password.text != nil)
    {
        [APUser authenticateUserWithUsername:_username.text password:_password.text sessionExpiresAfter:nil limitAPICallsTo:nil successHandler:^(APUser *user){
            if(_currentUser == nil)
                _currentUser = [[APUser alloc] init];
            _currentUser = user;
            [self dismissViewControllerAnimated:YES completion:nil];
        } failureHandler:^(APError *error) {
            NSLog(@"ERROR:%@",[error description]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Some error occurred" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self login];
    [textField resignFirstResponder];
    return YES;
}

@end
