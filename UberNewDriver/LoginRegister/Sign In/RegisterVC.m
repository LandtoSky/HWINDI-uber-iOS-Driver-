//
//  RegisterVC.m
//
//  Created by Adam on 08/01/16.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import "RegisterVC.h"
#import "AppDelegate.h"
#import "UIImageView+Download.h"
#import "CarTypeCell.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"
#import "UIImage+Resize.h"

@interface RegisterVC ()
{
    BOOL isProPicAdded;

    NSMutableDictionary *dictparam;
    NSMutableArray *arrType;
    NSMutableString *strTypeId;
    NSString *strLoginType;
    NSString *strSocialId;
}
@end

@implementation RegisterVC

@synthesize txtEmail,txtFirstName,txtLastName,txtPassword,txtAddress,txtPostalCode,txtNumber, txtTaxiNumber,txtTaxiModel;
@synthesize typeCollectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackBarItem];
    [self setNavBarTitle:@"Register"];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    isProPicAdded=NO;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    dictparam=[[NSMutableDictionary alloc] init];
    arrType=[[NSMutableArray alloc] init];
    [self getCarType];
    
    [self customFont];
    [self localizeString];
    
    self.btnRegister.enabled=FALSE;
    self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.frame.size.width/2;
    self.imgProfilePic.layer.borderWidth = 2.0f;
    self.imgProfilePic.layer.borderColor = [[UIColor whiteColor] CGColor];

    //For country calling code.
    /*NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSMutableArray *arrCountry = [[NSMutableArray alloc] init];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    arrCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", countryCode];
    NSArray *results = [arrCountry filteredArrayUsingPredicate:predicate];
    NSArray *code = [results valueForKey:@"phone-code"];
    [self.btnCountryCode setTitle:code[0] forState:UIControlStateNormal];*/
}
- (void)viewWillAppear:(BOOL)animated
{
    self.txtNumber.text = self.strPhoneNumber;
    [self.btnCountryCode setTitle:self.strCountryCode forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegular];
    self.txtLastName.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPassword.font=[UberStyleGuide fontRegular];
    self.txtNumber.font = [UberStyleGuide fontRegular];
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.txtPostalCode.font=[UberStyleGuide fontRegular];
    self.txtTaxiModel.font=[UberStyleGuide fontRegular];
    self.txtTaxiNumber.font=[UberStyleGuide fontRegular];
    
    self.btnRegister.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnSelectVehicle.titleLabel.font = [UberStyleGuide fontRegularBold];
    
}
-(void)localizeString
{
    [self.btnTermsConditions setTitle:NSLocalizedString(@"TERMS", nil) forState:UIControlStateNormal];
    
    NSAttributedString *email = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtEmail.attributedPlaceholder = email;
    NSAttributedString *password = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPassword.attributedPlaceholder = password;
    NSAttributedString *firstname = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIRSTNAME", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtFirstName.attributedPlaceholder = firstname;
    NSAttributedString *lastname = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LASTNAME", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtLastName.attributedPlaceholder = lastname;
    NSAttributedString *number = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PHONE", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtNumber.attributedPlaceholder = number;
    NSAttributedString *postal = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"POSTAL_CODE", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPostalCode.attributedPlaceholder = postal;
    NSAttributedString *address = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ADDRESS", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtAddress.attributedPlaceholder = address;
    NSAttributedString *taxiModel = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TAXI_MODEL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtTaxiModel.attributedPlaceholder = taxiModel;
    NSAttributedString *taxiNumber = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TAXI_NUMBER", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtTaxiNumber.attributedPlaceholder = taxiNumber;
    
}

#pragma mark -
#pragma mark - UIButton Action

- (IBAction)onClickFacebook:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"No Internet", nil)];
        return;
    }
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Facebook login failed. Error: %@", error);
        } else if (result.isCancelled) {
            NSLog(@"Facebook login got cancelled.");
        } else{ //Success
            NSLog(@"Success");
            [APPDELEGATE showLoadingWithTitle:@"Please wait"];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, first_name, last_name, picture, email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog(@"Failed fetching user information.");
                } else {
                    self.txtEmail.text = [result objectForKey:PREF_EMAIL];
                    self.txtFirstName.text = [result objectForKey:@"first_name"];
                    self.txtLastName.text = [result objectForKey:@"last_name"];
                    strLoginType = @"facebook";
                    strSocialId = [result objectForKey:PREF_USER_ID];
                   
                    NSURL *pictureURL1 = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [result objectForKey:PREF_USER_ID]]];
                    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL1];
                    UIImage *fbImage = [UIImage imageWithData:imageData];
                    [self.imgProfilePic setImage: fbImage];
                    isProPicAdded = YES;
                }
                [APPDELEGATE hideLoadingView];
            }];
        }
    }];
}

- (IBAction)onClickGoogle:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"No Internet", nil)];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
}

-(BOOL)validateFields
{
    if(self.txtFirstName.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_FIRST_NAME", nil)];
    }
    else if(self.txtLastName.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_LAST_NAME", nil)];
    }
    else if (![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_VALID_EMAIL", nil)];
    }
    else if(self.txtEmail.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_EMAIL", nil)];
    }
    else if(self.txtNumber.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER", nil)];
    }
    else if(self.txtNumber.text.length<9)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER_MIN", nil)];
    }
    else if(self.txtTaxiModel.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_TAXI_MODEL", nil)];
    }
    else if(self.txtTaxiNumber.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_TAXI_NUMBER", nil)];
    }
    else if(strTypeId==nil)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_CAR_TYPE", nil)];
    }
    else if(isProPicAdded==NO)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_PHOTO", nil)];
    }
    else {
        return true;
    }
    return false;
}
- (IBAction)onClickRegister:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"No Internet", nil)];
        return;
    }
    if(![self validateFields]){
        NSLog(@"Incorrect values");
        return;
    }

    [self registerUser];
}

- (IBAction)onClickTermsConditions:(id)sender
{
    [self performSegueWithIdentifier:@"pushToTerms" sender:self];
}

- (IBAction)onClickCheckAgree:(id)sender
{
    BOOL status = self.btnCheckAgree.selected;
    self.btnCheckAgree.selected = !status;
    self.btnRegister.enabled = self.btnCheckAgree.selected;
}

- (IBAction)onClickSelectVehicle:(id)sender
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        float closeY=(iOSDeviceScreenSize.height-self.btnSelectVehicle.frame.size.height-self.btnRegister.frame.size.height-2.0f);
        float openY=iOSDeviceScreenSize.height-self.viewSelectVehicle.frame.size.height;
        
        if (self.viewSelectVehicle.frame.origin.y==closeY)
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.viewSelectVehicle.frame=CGRectMake(0, openY, self.viewSelectVehicle.frame.size.width, self.viewSelectVehicle.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.viewSelectVehicle.frame=CGRectMake(0, closeY, self.viewSelectVehicle.frame.size.width, self.viewSelectVehicle.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        
    }
}

- (IBAction)onClickCamera:(id)sender {
    [self takePhoto];
}

- (IBAction)onClickPicture:(id)sender {
    [self chooseFromLibaray];
}

#pragma mark Load Photo
-(void)takePhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate =self;
        imagePickerController.allowsEditing=YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)];
    }
}

-(void)chooseFromLibaray
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing=YES;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    //UIImage *resizedImage = [img resizedImageToSize:CGSizeMake(300.0f, 300.0f)];
    
    self.imgProfilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.imgProfilePic.clipsToBounds = YES;
    isProPicAdded=YES;
    self.imgProfilePic.image=img;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)setImage:(UIImage *)image
{
    self.imgProfilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.imgProfilePic.clipsToBounds = YES;
    self.imgProfilePic.image=image;
    isProPicAdded=YES;
}
#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrType.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
    
    NSMutableDictionary *dictType=[arrType objectAtIndex:indexPath.row];

    if ([strTypeId intValue]==[[dictType valueForKey:@"id"]intValue])
    {
        cell.imgCheck.hidden=NO;
    }
    else
    {
        cell.imgCheck.hidden=YES;
    }


    cell.lblTitle.text=[dictType valueForKey:@"name"];
    NSString* iconURL = [dictType valueForKey:@"icon"];
    if(iconURL != nil){
        [cell.imgType downloadFromURL:iconURL withPlaceholder:nil];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];

    NSMutableDictionary *dictType=[arrType objectAtIndex:indexPath.row];
    strTypeId = [dictType valueForKey:@"id"];
    [self.typeCollectionView reloadData];
}

#pragma mark-
#pragma mark- Text Field Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==self.txtNumber  || textField==self.txtPostalCode)
    {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
   
    if(textField==self.txtFirstName)
        [self.txtLastName becomeFirstResponder];
    else if(textField==self.txtLastName)
        [self.txtEmail becomeFirstResponder];
    else if(textField==self.txtEmail)
        [self.txtPassword becomeFirstResponder];
    else if(textField==self.txtNumber)
        [self.txtAddress becomeFirstResponder];
    else if(textField==self.txtPassword)
        [self.txtNumber becomeFirstResponder];
    else if(textField==self.txtAddress)
        [self.txtPostalCode becomeFirstResponder];
    else if(textField==self.txtPostalCode)
        [self.txtTaxiModel becomeFirstResponder];
    else if(textField==self.txtTaxiModel)
        [self.txtTaxiNumber becomeFirstResponder];
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark-
#pragma mark- Get WalerType Method

-(void)getCarType
{
    if([APPDELEGATE connected])
    {
       AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_WALKER_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"Check Request= %@",response);
             if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrType=[response valueForKey:@"types"];
                     [typeCollectionView reloadData];
                 }
             }
             
         }];
    }
}
#pragma mark - Google Signin
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    NSLog(@"Received Google authentication response! Error: %@", error);
    if (error != nil) {
        // There was an error obtaining the Google OAuth token, display a dialog
        NSString *message = [NSString stringWithFormat:@"There was an error logging into Google: %@",
                             [error localizedDescription]];
        [APPDELEGATE showAlert:message];
    } else {
        txtEmail.text = user.profile.email;
        strLoginType=@"google";
        strSocialId = user.authentication.idToken;
        NSArray* name = [user.profile.name componentsSeparatedByString:@" "];
        txtFirstName.text = [name objectAtIndex:0];
        txtLastName.text = [name objectAtIndex:1];
    }
}
- (void)registerUser {
    
    NSString *strNumber=[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text, txtNumber.text];
    
    [dictparam setObject:txtFirstName.text forKey:PARAM_FIRST_NAME];
    [dictparam setObject:txtLastName.text forKey:PARAM_LAST_NAME];
    [dictparam setObject:txtEmail.text forKey:PARAM_EMAIL];
    [dictparam setObject:txtPassword.text forKey:PARAM_PASSWORD];
    [dictparam setObject:strNumber forKey:PARAM_PHONE];
    
    [dictparam setObject:txtAddress.text forKey:PARAM_ADDRESS];
    [dictparam setObject:txtPostalCode.text forKey:PARAM_ZIPCODE];
    [dictparam setObject:device_token forKey:PARAM_DEVICE_TOKEN];
    [dictparam setObject:@"ios" forKey:PARAM_DEVICE_TYPE];
    
    [dictparam setObject:txtTaxiModel.text forKey:PARAM_TAXI_MODEL];
    [dictparam setObject:txtTaxiNumber.text forKey:PARAM_TAXI_NUMBER];

    [dictparam setObject:strTypeId forKey:PARAM_WALKER_TYPE];
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    [dictparam setObject:countryCode forKey:PARAM_COUNTRY];
    
    //[dictparam setObject:@"a" forKey:PARAM_STATE];
    //[dictparam setObject:@"" forKey:PARAM_PICTURE];
    //[dictparam setObject:@"BIO" forKey:PARAM_BIO];
    
    if(strSocialId == nil)
    {
        [dictparam setObject:@"manual" forKey:PARAM_LOGIN_BY];
    } else {
        [dictparam setObject:strSocialId forKey:PARAM_LOGIN_BY];
    }
    [APPDELEGATE showLoadingWithTitle:@"Please Wait"];
    UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.imgProfilePic.image];
 
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_REGISTER withParamDataImage:dictparam andImage:imgUpload withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [APPDELEGATE showToastMessage:(NSLocalizedString(@"REGISTER_SUCCESS", nil))];
                 arrUser=response;
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else
             {
                 NSMutableArray *err=[[NSMutableArray alloc]init];
                 err=[response valueForKey:@"error_messages"];
                 if (err.count==0)
                 {
                     [APPDELEGATE showAlert:[response valueForKey:@"error"]];
                 }
                 else
                 {
                     [APPDELEGATE showAlert:[NSString stringWithFormat:@"%@",[err objectAtIndex:0]]];
                 }
             }
         }
         NSLog(@"REGISTER RESPONSE --> %@",response);
     }];
}
@end
