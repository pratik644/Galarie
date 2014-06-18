Building a photo album app using Appacitive–iOS–SDK
==================

Hello and welcome to the second part of the tutorial series — “Working with Appacitive iOS SDK”.

In the Part-1 of the tutorial series we saw how to create a simple app for finding shopping deals near your location. We also had a small informal introduction of the Appacitive platform. If you missed the Part-1 of the tutorial, I urge you to first go through it and then continue with the Part-2 of the tutorial so that you can get a clearer picture about what appacitive is and how it works. 

Now lets begin the Part-2 of the tutorial. In this tutorial we are going to make an app called galarie. It’s a simple photo album app that allows you to share photos form your device and upload them to your albums. For the sake of this tutorial you will need to create an app on Appacitive and the model for the app as described below:

| TYPE  | PROPERTIES                          |
|-------|-------------------------------------|
| album | name as string                      |
| photo | filename as string; comment as text |    

We will also need a type called `user` but there is no need to create this type since it provided out-of-the-box by Appacitive along with some really useful properties.

| RELATION   | FROM TYPE | TO TYPE | MULTIPLICITY | PROPERTIES   |
|------------|-----------|---------|--------------|--------------|
| belongs_to | photo     | album   | many to many | -none-       |
| commented  | user      | photo   | many to one  | text as text |
| likes      | user      | photo   | many to one  | -none-       |

Upload some pictures on Appacitive and name them appropriately since the same name goes in to the filename property of the photo type. Refer the first screenshot below.

Create two albums named _Paris_ and _Disneyland_. Add entries for the files shown in the screenshot below in the photo type. There should be eleven entries as per the screenshot, but you can have as many or as few as you would like. 

Go to the explorer on the Appacitive portal and add all the types to the canvas. Carefully connect all the Disneyland photos to the Disneyland album and all the Paris photos to the Paris album. Also connect users to the photos with like and comment relation and set the text property for each comment relation. Refer to the second screenshot below.

<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/ss1.png" style="maxwidth:100%">

<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/ss2.png" style="maxwidth:100%">

Now that our model is set-up, lets write some code to build an app that can consume the data from our model and present it to us in a visually aesthetic way.

Open Xcode and create a new empty application, name it galarie and select iPhone from the devices drop down box. Add the AppacitiveSDK framework bundle to your project. 

####REGISTERING THE API KEY

In order to make communicate with the Appacitive back end you need to first register the APIkey in to your app. To do so, open the AppdDelegate.m and in the application:didFinishLaunchingWithOptions: method add the following line of code to register the APIKey in to your app. If you are using the live environment make sure to set the useLiveenvironment parameter to YES.

```objectivec
[Appacitive registerAPIKey:@"YOUR_API_KEY_HERE" useLiveEnvironment:NO];
```

####IMPLEMENTING AUTHENTICATION:

Add a new file to the project. Select Objective-C class form the template. Name the class `LoginViewController` and select `UIViewController` form the Subclass of drop down menu. Make sure the _Targeted for iPad_ and _With XIB for user interface_ are unchecked.

Open the LoginViewController.h file and add two IBOutlets of type UITextfield for the username and password fields. Also add an action method for Login.

```objectivec
#import <Appacitive/AppacitiveSDK.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property IBOutlet UITextField *username;
@property IBOutlet UITextField *password;

- (IBAction)login;
+ (APUser*) getCurrentUser;

@end
```

The `getCurrentUser` method will return the currently logged-in user’s object. We will need it later in the app when we try to comment on a photo or like a photo.

Open the LoginViewController.m file. Replace all the existing code with the code below:

```objectivec
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
```

In the `login` method, we make a call to the Appacitive SDK’s APUser class method `authenticateUserWithUserName:password:successHandler:failureHandler`. This method returns the authenticated user’s object of type APUser in the successBlock. We store this object in our static APUser reference so that we can use this user object to make connections to other objects when the user interacts with them. We also provide a getter method getCurrentUser for the current user that returns the static current user reference that we stored earlier while authenticating the user.

####IMPLEMENTING ALBUM TABLE VIEW

Once the user is logged in, we need to show him a list of available albums. Add a UITableView to the storyboard and make it the root controller of the navigation controller. In the app delegate, after setting up the navigation controller and the root view controller, add the login view as the modal view to the table view. Make sure to correctly set all the referencing outlets, actions and segues.

Open the `AlbumListViewController.h` file and replace the code with the code below.

```objectivec
@interface AlbumListViewController : UITableViewController

- (IBAction) cameraButtonTapped;

@end
```

We have an action method here called `cameraButtonTapped` that will be used when the user will tap the camera button to take a picture to upload it.

Open the `AlbumListViewController.m` file and replace all the code with the code below. Do not get overwhelmed with the amount of code in it, most of the code is used to customize the user interface that you can safely skip and most part of the rest of the code is provided out-of-the box by Xcode.

```objectivec
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
```

Let’s go through the code to understand what is happening here. Firstly notice that our class conforms to the `UITableViewDataSource`, `UITableViewDelegate` and `UIImagePickerControllerDelegate`. The table view data source and delegate are required to display our data in the UITableView. The image picker delegate is required for taking a picture with the device camera and uploading it.

In the `cameraButtonTapped` method we first check if the device has a camera and display appropriate message if it does not. As you may know by now that this check is required because although all Apple Devices do have a camera, the iOS simulator does not and since most of you may attempt to test the app on the simulator first, we would not want our app to crash just because we accidentally tried to open the camera in the simulator. If the device does have a camera, then we initialize a `UIImagePickerController` object, set our class as a delegate for the `UIImagePickerController`, set the source type as camera and we present the `UIImagePickerController` which will open the camera for us. But what do we do after taking the picture with the camera?

Well, we need to implement another `UIImagePickerController` delegate method called `didFinishPickingMediaWithInfo` that will give us a reference to the photo we just clicked with the camera so we can upload it. In this method we grab the newly clicked photo and pass it to the `UploadModalViewController` that will take care of uploading the picture which we will see later.

In `imagePickerControllerDidCancel` we simply remove the picker view if the user presses the cancel button in the picker view.

In the `viewDidLoad method`, we use the APObject class’s class method `searchAllObjectsWithTypeName:successHandler:` This method will return an array of APObjects of type album. We copy this array into our own array so that we can use them later and we reload the table view to refresh it with the new data i.e. the list of albums we just fetched.

Now lets implement the UITableView datasource methods. In the `numberOfSectionsInTableView` we return 1 since we need only 1 section in our table view. In the `numberOfRowsInSection` we return the length of the `albums` array that holds all the albums we fetched from Appacitive.

In the `cellForRowAtIndexPath` method we set the UITableViewCell’s text label to the `name` of the album and its accessibilityValue to the `objectId` of the album object. We will need this objectId later to fetch all the photos of the selected album.

In the `didSelectRowAtIndexPath` we instantiate a `PhotoViewController` object and set the `selectedAlbumId` property of the controller to the accessibility value of the cell which is the `objecteId` of the selected album. We then push the `PhotoViewController` on the current view by performing a segue that we setup in the storyboard.

In the `prepareForSegue:sender:` method, we first check the segue identifier, if it is the segue calling the `UploadViewController` modal view, then we instantiate an `UploadModalViewController` and pass it the list of albums we had fetched previously and we also pass it the photo that we had clicked with the device camera.


####IMPLEMENTING PHOTO UPLOAD

Add another View Controller, name it `UploadModalViewController`. Open the `UploadModalViewController.h` file and replace the code with the code below.

```objectivec
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
```

Open the `UploadModalViewController` and replace the code with the code below. Again, do not let the volume of the code overwhelm you. Just read the explanation that follows the code and you should be fine.

```objectivec
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
```

Ok, so what all do we have here. Firstly, our view controller conforms to the following protocols: `UIPickerViewDataSource`, `UIPickerViewDelegate`, `UITextFieldDelegate` ,`UIAlertViewDelegate`, `MBProgressHUDDelegate`.

Apart from `MBProgressHudDelegate`, you must be familiar with all the other protocols. Lets talk a bit about the MBProgressHudDelegate. MBProgressHud is an easy to use progress indicator for iOS that includes both fixed and indeterminate styles. [Here](https://github.com/jdg/MBProgressHUD) is the link to the GitHub page. It is a very nice control that allows you to show a blocking activity indicator view for operations that might take some time to complete and when you wouldn’t want user to interfere or fiddle when the operation is in progress. We will be using this control in our app to show an activity indicator when an image is being uploaded, since with the newer higher resolution camera devices like the iPhone 5 and iPhone 5S, the image size might be large enough to consume significant amount of time to upload the picture.

The `setImage` and the `setAlbumList` are setter methods that simply set the object values.

The `cancelButtonTapped` action method simply dismisses the UploadModalViewController form view when the user taps on the cancel button.

Lets implement the UIPickerView datasource and delegate methods. We will use the UIPickerView to display the list of albums available on Appacitive.

In the `pickerView:numberOfComponentsInPickerView:` method we return 1 since we only need a single component for displaying the album names.

In the `pickerView:numberOfRowsInComponent:` we return the length of the `albumList` array since it holds all the album objects.

In `pickerView:titleForRow:forComponent:` we set the title of the current row to the title of the album at the row number index in the `albumList` array.

In `pickerView:didSelectRow:inComponent` we set the `albumForImage` object to the selected object from the `albumList` array.

In the `viewDidLoad` method we set the thumbnailImage to an image for the `thumbnailImageView`.

In the `uploadButtonTaped` method we first validate the name of the photo that the user has entered for uploading. If the validation passes then we present an MBProgressHUD view to display a large blocking activity indicator to prevent user interruptions while the photo is being uploaded to the server.

We use the APFile class method `uploadFileWithName:data:validUrlForTime:contentType:successHandler:failureHandler:` method to upload the photo we clicked with the camera. If the upload is successful, we need to create a new APObject of type `photo` that will refer to the newly uploaded photo and we also need to create a connection of type `belongs_to` between the newly created photo APObject and the selected album APObject. This is what we have done in the rest of the code.

If the upload is successful, we need to remove the current modal view since there is nothing more the user needs to do on this view. Therefore we present a UIAlertView when the upload is successful and we set our UploadModalViewController as the delegate of the UIAlertView so when the user presses the dismiss button on the UIAlertView, we can dismiss the UploadModalViewController. Make sure that in the UIAlertView for failure cases have delegate set to nil otherwise on pressing the dismiss button on the failure message UIAlertView, it will call the delegate we implemented and dismiss the UploadModalViewController which is something we do not want to happen. This is what we do in the `alertView:didDismissWithButtonIndex:` delegate method.


####DOWNLOADING PHOTOS

Now lets move on to the `PhotoViewController`. In the `AlbumListViewController`, when the user selects an album we push the `PhotoViewController` via a segue. So now lets set up the `PhotoViewController` to display a UITableView with photos in the UITableViewCells.

Create a new `UITableViewController` subclass, name it `PhotoViewController`. In the storyboard, drag a table view controller on the canvas and change its class to `PhotoViewController`. Add a segue from the `AlbumListViewController` to the newly added table view controller.

Open the `PhotoViewController.h` file and replace the code with the code below.

```objectivec
@interface PhotoViewController : UITableViewController

-(void) setAlbumId:(NSString*)albumId;

@end
```

Open the `PhotoViewController.m` file and replace the code with the code below.

```objectivec
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
```

The `photoList` array will hold the photo APObjects that we retrieve from our model at Appacitive and it also serves as the data source for the UITableView that we will use to display the photos. The `index` integer will hold the integer index of the table view cell of the photo that the user tapped on. The `selectedAlbumId` holds the `objectId` of the album whose photos we need to retrieve and its set by the source view controller viz. the `AlbumListViewController` that triggered the segue to push this view controller on to the navigation stack. The `images` array holds UIImage objects of the photos that we download from Appacitive.

In `viewDidLoad` method we use the APConnection class method  `fetchObjectsConnectedToObjectOfType:withObjectId:withRelationType:successHandler:failureHandler:` to fetch all the APObjects that are connected to the type album with a relation of type `belongs_to`. In short we are fetching all the APObjects connected to the APObject  of type `album` with a relation type `belongs_to`. This method returns an array of APGraphNode objects. We iterate over the array of APGraphNode objects and extract the photo `APObjects` and put them in the `photoList` array. 

We are inserting an NSNull object for every photo object we insert in to the `photoList` array. We do so because the image download operation is going to be asynchronous and we want to reserve a place for every photo that will download in the background and while the download is not complete we want the table view to show an activity indicator for every image that is going to load. So we create an array of NSNull objects with the exact same length/size as the number of photos we are going to display and we reload the UITableView and if the `tableView:cellForRowAtIndexPath:` finds a null object in the data source array, it will show an activity indicator and as soon as we fetch an image and insert it into the `images` array, we reload the tableView to show us that image in the respective table view cell. This is a hack and I am sure there are better and creative ways to achieve this but for the sake of this tutorial, I have opted for the first, fastest solution that came to my mind. Feel free to use a better technique of your own.

As soon as the we fill the `images` array with NSNull objects equal to the number of images are going to download, we reload the UITableView to start showing the activity indicators for all the cells which will later be occupied by the photos as soon as they get downloaded.

To begin downloading the images, we iterate over the `photoList` array that holds photo APObjects and we use the `filename` property of every photo APObject as the url of the image to be downloaded. We then  use the APFile class’s instance method `downloadFileWithName:urlExpiresAfter:successHandler:failureHandler:` method to download the photos one by one and start substituting them in the respective UITAbleViewCells.

In `tableView:cellForRowAtIndexPath` method we check the datasource viz. the `images` array and if we find an image we display it and if we find an NSNull object (the one we deliberately inserted in the array) we show an activity indicator so that the first time the user is presented with the view he does not land on an empty tableView. 

In the `tableView:didSelectRowAtIndexPath:` we save the current tableView index to our class’s private variable and we trigger a segue. The segue will first check for the implementation of `prepareForSegue:sender:` method to perform any extra setup that the user wants before the new view is brought in. In our case, we use the saved index as an index of the `photoList` array to pass the selected photo APObject to the next view controller which will take care of displaying details of the selected photo.

In `tableView:heightForRowAtIndexPath:` we set the height of the cell to a custom value of 230 pixels so that we have a good amount of real-estate in each cell to display the photos.

####DISPLAYING THE PHOTO DETAILS 

Add a new `UIViewController` subclass to the project and name it `PhotoDetailsViewController`. Add a view controller to the storyboard, set its class to the newly added `PhotoDetailViewController`. Add a segue from the `PhotoViewController` to the `PhotoDetailViewController` and set the identifier of the segue as `details`. Drag three UILabels, two UITextViews and a UIBarButton items on the new empty view. Arrange and label them as shown in the screenshot of the storyboard above.

Make sure you hook-up the reference outlets for the UITextViews and the UILabel with the IBOutlet properties that we are going to declare in the PhotoDetailsViewController.h file below.


Open the `PhotoDetailsViewController.h` file and replace all the code with the code below.

```objectivec
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
```

The first two methods are pretty straight forward. First is the setter for setting the `selectedPhoto` object and second one is an action method that will trigger the segue that will present the actions view controller where the user can like the current photo and also leave a comment for the photo.

In the `viewDidAppear:` method we instantiate an APGraphNode object called node and we use it to call the instance method `applyProjectionGraphQuery:usingPlaceHolders:forObjectsIds:successHandler:failureHandler` of APGraphNode class. This method will execute a graph projection query that you created and saved on Appacitive. Refer to the screenshots at the beginning of this tutorial for creating a projection graph query on Appacitive. 

The method will populate our node object with appropriate objects and connections that we had configured in the Appacitive portal. We iterate over the graph node objects to extract the users that liked the selected photo as well as the users that commented on the selected photo along with the comment. We set the values of the two UITextViews with the data we just extracted from the server. 

####IMPLEMENTING THE ACTION MODAL VIEW

For the current user to be able to like the selected photo or to make a comment on the selected photo we need to implement an action modal view. Add a new ViewController subclass and name it `ActionModalViewController`. Also add a ViewController in the storyboard and add a segue from the `PhotoDetailViewController` to the newly added view. Set the custom class of the newly added view to `ActionModalViewController` class. Drag 3 UIButtons, a UIImage and a UITextView on to the storyboard and lay them out as shown in the screenshot at the beginning of the tutorial.

Make sure you set the referencing outlets and actions for all the UI elements after you declare them in the header file as shown below.

Open the ActionModalViewController.h file and replace its code with the code below.

```objectivec
#import <UIKit/UIKit.h>
#import <AppacitiveSDK/AppacitiveSDK.h>

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
```

Open the ActionModalViewController.m file and replace its code with the code below.

```objectivec
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
```

The first three method implementations are pretty straightforward so lets jump to the action method `doneButtonTapped`. This method will be called when the user presses the done button on the `ActionModalView`. There are two types of actions that the user can perform on this view. He can like the current photo and he can also leave a comment on the photo. We save his inputs in the two private variables viz. the `like` variable of type BOOL and the `comment` variable of type NSString. When the user presses the done button, we examine these two variable to figure out the actions the user wishes to perform. If the boolean like value is set to `YES`, we create an APConnection of type `likes` between the selected photo APObject and the currently logged-in APUser object. If the user has entered a comment, we create an APConnection between the selected photo APObject and the currently logged-in APUser object with the `comment` relation type. For the `comment` APConnection, we set the text property to the comment entered by the user since the comment text is saved in the APConnection’s text property.

After we are done with creating the connection, we dismiss the action view controller and take the user back to the `PhotoDetailViewController` where he can now see his own like status and comments if he made any.

<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/ss3.png" style="maxwidth:100%">

<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss1.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss2.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss3.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss4.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss5.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss6.PNG" style="width:30%; float:left; padding:1.6%;">
<img alt="scrrenshot" src="http://devcenter.appacitive.com/ios/samples/galarie/sss7.PNG" style="width:30%; padding:1.6%;">


####CONCLUSION
In this tutorial we covered a lot of aspects of the functionalities provided by the Appacitive platform. Most importantly we learned to deal with downloading and uploading files to and from Appacitive. We also learned to create APConnections between connected APObjects and we also learned how to fetch connected APObjects. One most important feature that we learned in this tutorial is the projection graph search. It comes in really handy when you need to fetch, a bunch of objects of different types chained by connections of different relation types, in one single call.