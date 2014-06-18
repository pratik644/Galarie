//
//  ViewController.h
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//
#import <Appacitive/AppacitiveSDK.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property IBOutlet UITextField *username;
@property IBOutlet UITextField *password;

- (IBAction)login;
+ (APUser*) getCurrentUser;

@end
