//
//  UploadModalViewController.m
//  Galarie
//
//  Created by Pratik on 03-03-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "UploadModalViewController.h"
#import "MBProgressHUD.h"

@interface UploadModalViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate ,UIAlertViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *_busyView;
}

@end

@implementation UploadModalViewController

- (void)setImage:(UIImage*)image {
    _thumbnailImage = image;
}

- (void)setAlbumList:(NSArray *)array {
    _albumList = [[NSArray alloc] init];
    _albumList = array;
}

- (IBAction)cancelButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PickerView DataSource Implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _albumList.count;
}

#pragma mark PickerView Delegate Implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_albumList objectAtIndex:row] getPropertyWithKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _albumForImage = [_albumList objectAtIndex:row];
}

#pragma mark TextField delegate implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UploadModalViewcontroller implemntation

- (void)viewDidLoad {
    [super viewDidLoad];
    [_thumbnailImageView setImage:_thumbnailImage];
    [_thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
}

-(IBAction)uploadButtonTapped {
    self.imageName.text = [self.imageName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(self.imageName.text == nil || [self.imageName.text  isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Name" message:@"Please enter a valid name for the image." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        if(_busyView == nil) {
            _busyView = [[MBProgressHUD alloc] initWithView:self.view];
        }
        [self.view addSubview:_busyView];
        _busyView.delegate = self;
        [_busyView show:YES];
        
        [APFile uploadFileWithName:self.imageName.text data:UIImageJPEGRepresentation(_thumbnailImageView.image, 0) urlExpiresAfter:@10 contentType:@"image/jpeg" successHandler:^(NSDictionary *result) {
            
            APObject *photoObject = [[APObject alloc] initWithTypeName:@"photo"];
            [photoObject addPropertyWithKey:@"filename" value:self.imageName.text];
            
            APObject *albumObject = [[APObject alloc] initWithTypeName:@"album"];
            albumObject = _albumForImage;
            
            [photoObject saveObjectWithSuccessHandler:^(NSDictionary *result) {
                APConnection *connection = [[APConnection alloc] initWithRelationType:@"belongs_to"];
                [connection createConnectionWithObjectA:photoObject objectB:albumObject successHandler:^{
                    [_busyView removeFromSuperview];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image uploded" message:@"Image uploaded successfully." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                    [alert show];
                    
                } failureHandler:^(APError *error) {
                    [_busyView removeFromSuperview];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:@"Image could not be uploaded, try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                    [alert show];
                }];
                
            } failureHandler:^(APError *error) {
                [_busyView removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:@"Image could not be uploaded, try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }];
            
        } failureHandler:^(APError *error) {
            [_busyView removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:@"Image could not be uploaded, try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}

#pragma mark AlertView delegate implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_busyView hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
