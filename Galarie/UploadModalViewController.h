//
//  UploadModalViewController.h
//  Galarie
//
//  Created by Pratik on 03-03-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import <Appacitive/AppacitiveSDK.h>

@interface UploadModalViewController : UIViewController {
    NSArray *_albumList;
    APObject *_albumForImage;
    UIImage *_thumbnailImage;
}

@property (strong, nonatomic) IBOutlet UITextField *imageName;
@property (strong, nonatomic) IBOutlet UIPickerView *albumPicker;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;

- (void) setImage:(UIImage*)image;
- (void) setAlbumList:(NSArray*)array;
- (IBAction) uploadButtonTapped;
- (IBAction) cancelButtonTapped;

@end
