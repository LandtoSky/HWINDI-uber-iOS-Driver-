//
//  ProfileVC.m
//
//  Created by Adam on 12/13/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import "UtilityClass.h"
#import "PickMeUpMapVC.h"
#import "ArrivedMapVC.h"
#import "FeedBackVC.h"

@interface ProfileVC ()
{
    BOOL internet;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strPassword;
}

@end

@implementation ProfileVC

@synthesize txtAddress,title,txtEmail,txtName,txtNumber,txtZip,txtPassword,btnProPic,txtNewPassword,bgNewPwd,bgPwd,txtTaxiModel,txtTaxiNumber,txtReNewPassword,bgReNewPwd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBackBarItem];
    [super setNavBarTitle:@"Profile"];
    
    [self.profileImage applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self.ScrollProfile setScrollEnabled:YES];
    [self.ScrollProfile setContentSize:CGSizeMake(320, 465)];
    
    [self localizeString];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strPassword=[pref objectForKey:PREF_PASSWORD];
    
    NSString * name = [NSString stringWithFormat:@"%@ %@", [arrUser valueForKey:@"first_name"], [arrUser valueForKey:@"last_name"]];
    txtName.text=name;
    txtEmail.text=[arrUser valueForKey:@"email"];
    txtNumber.text=[arrUser valueForKey:@"phone"];
    txtAddress.text=[arrUser valueForKey:@"address"];
    txtZip.text=[arrUser valueForKey:@"zipcode"];
    txtTaxiModel.text=[arrUser valueForKey:@"car_model"];
    txtTaxiNumber.text=[arrUser valueForKey:@"car_number"];

    txtPassword.text=@"";
    txtNewPassword.text=@"";
    txtReNewPassword.text=@"";
    
    [self.profileImage downloadFromURL:[arrUser valueForKey:@"picture"] withPlaceholder:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lblCarModelInfo.hidden=YES;
    self.imgCarModelInfo.hidden=YES;
    self.lblCarNumberInfo.hidden=YES;
    self.imgCarNumberInfo.hidden=YES;
    self.lblEmailInfo.hidden=YES;
    self.imgEmailInfo.hidden=YES;
    self.btnInfo1.tag=0;
    self.btnInfo2.tag=0;
    self.btnInfo3.tag=0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Custom Font

-(void)customFont
{
    self.txtName.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.txtZip.font=[UberStyleGuide fontRegular];
    
    self.btnUpdate=[APPDELEGATE setBoldFontDiscriptor:self.btnUpdate];
}

-(void)localizeString
{
   
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NAME", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtName.attributedPlaceholder = name;
    NSAttributedString *email = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtEmail.attributedPlaceholder = email;
    NSAttributedString *number = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NUMBER", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtNumber.attributedPlaceholder = number;
    NSAttributedString *address = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMADDRESSAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtAddress.attributedPlaceholder = address;
    NSAttributedString *password = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CURRENT_PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPassword.attributedPlaceholder = password;
    NSAttributedString *newPassword = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NEW_PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtNewPassword.attributedPlaceholder = newPassword;
    NSAttributedString *confirmPassword = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CONFIRM_PASSWORD", nil)
                                                                          attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtReNewPassword.attributedPlaceholder = confirmPassword;
    NSAttributedString *zipCode = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ZIPCODE", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtZip.attributedPlaceholder = zipCode;
    
    NSAttributedString *taxiModel = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TAXI_MODEL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtTaxiModel.attributedPlaceholder = taxiModel;
    NSAttributedString *taxiNumber = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TAXI_NUMBER", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtTaxiModel.attributedPlaceholder = taxiNumber;
    
    self.lblEmailInfo.text = NSLocalizedString(@"NOT_EDITABLE", nil);
    self.lblCarNumberInfo.text = NSLocalizedString(@"NOT_EDITABLE", nil);
    self.lblCarModelInfo.text = NSLocalizedString(@"NOT_EDITABLE", nil);

}

#pragma mark- TextField Enable and Disable

-(void)updateProfile
{
    NSLog(@"\n Update Profile");
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"UPDATING_PROFILE", nil)];
    internet=[APPDELEGATE connected];
    
    if(internet)
    {
            NSMutableDictionary *dictparam;
            dictparam= [[NSMutableDictionary alloc]init];
            
            [dictparam setObject:txtNumber.text forKey:PARAM_PHONE];
            [dictparam setObject:txtPassword.text forKey:PARAM_OLDPASSWORD];
            [dictparam setObject:txtNewPassword.text forKey:PARAM_NEWPASSWORD];

            [dictparam setObject:txtAddress.text forKey:PARAM_ADDRESS];
            [dictparam setObject:txtZip.text forKey:PARAM_ZIPCODE];
        
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.profileImage.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPDATE_PROFILE withParamDataImage:dictparam andImage:imgUpload withBlock:^(id response, NSError *error)
             {
                 
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         arrUser=response;
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_UPDATED", nil)];

                         [self.profileImage downloadFromURL:[arrUser valueForKey:@"picture"] withPlaceholder:nil];
                     }
                     else
                     {
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Profile Update Fail" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                         [alert show];
                     }
                 }
                 
                 [APPDELEGATE hideLoadingView];
                 
                 NSLog(@"REGISTER RESPONSE --> %@",response);
             }];

    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No Internet", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }

}
#pragma mark-
#pragma mark- Button Method

- (IBAction)LogOutBtnPressed:(id)sender
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    
    [pref synchronize];
    [pref removeObjectForKey:PARAM_REQUEST_ID];
    [pref removeObjectForKey:PARAM_SOCIAL_ID];
    [pref removeObjectForKey:PREF_EMAIL];
    [pref removeObjectForKey:PREF_LOGIN_BY];
    [pref removeObjectForKey:PREF_PASSWORD];
    [pref setBool:NO forKey:PREF_IS_LOGIN];
    
    [self.navigationController.navigationController    popToRootViewControllerAnimated:YES];
}

- (IBAction)updateBtnPressed:(id)sender
{
    internet=[APPDELEGATE connected];
    if (self.txtNewPassword.text.length>=1 || self.txtReNewPassword.text.length>=1)
    {
        if ([txtNewPassword.text isEqualToString:txtReNewPassword.text])
        {
            [self updateProfile];
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Profile Update Fail" message:NSLocalizedString(@"NOT_MATCH_RETYPE",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        [self updateProfile];
    }
    
}

- (IBAction)backBtnPressed:(id)sender
{
    NSArray *currentControllers = self.navigationController.viewControllers;
    NSMutableArray *newControllers = [NSMutableArray
                                      arrayWithArray:currentControllers];
    UIViewController *obj=nil;
    
    for (int i=0; i<newControllers.count; i++)
    {
        UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
        if ([vc isKindOfClass:[FeedBackVC class]])
        {
            obj = (FeedBackVC *)vc;
        }
        else if ([vc isKindOfClass:[ArrivedMapVC class]])
        {
            obj = (ArrivedMapVC *)vc;
        }
        else if ([vc isKindOfClass:[PickMeUpMapVC class]])
        {
            obj = (PickMeUpMapVC *)vc;
        }
        
    }
    [self.navigationController popToViewController:obj animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)imgPicBtnPressed:(id)sender
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Select Image", nil];
    action.tag=10001;
    [action showInView:self.view];
    
}


- (IBAction)onClickEmailInfo:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (btn.tag==0)
    {
        btn.tag=1;
        self.lblEmailInfo.hidden=NO;
        self.imgEmailInfo.hidden=NO;
    }
    else
    {
        btn.tag=0;
        self.lblEmailInfo.hidden=YES;
        self.imgEmailInfo.hidden=YES;
    }

}

- (IBAction)onClickTaxiModelInfo:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (btn.tag==0)
    {
        btn.tag=1;
        self.lblCarModelInfo.hidden=NO;
        self.imgCarModelInfo.hidden=NO;
    }
    else
    {
        btn.tag=0;
        self.lblCarModelInfo.hidden=YES;
        self.imgCarModelInfo.hidden=YES;
    }
}

- (IBAction)onClickTaxiNoInfo:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if (btn.tag==0)
    {
        btn.tag=1;
        self.lblCarNumberInfo.hidden=NO;
        self.imgCarNumberInfo.hidden=NO;
    }
    else
    {
        btn.tag=0;
        self.lblCarNumberInfo.hidden=YES;
        self.imgCarNumberInfo.hidden=YES;
    }

}

#pragma mark -
#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
        case 3:
            break;
    }
}

-(void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate =self;
        imagePickerController.allowsEditing=YES;

        imagePickerController.view.tag = 102;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else
    {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alt show];
    }
}

-(void)chooseFromLibaray
{
    // Set up the image picker controller and add it to the view

    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
   
    imagePickerController.delegate =self;
    
     imagePickerController.allowsEditing=YES;
    imagePickerController.view.tag = 102;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.profileImage.image=[info objectForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField     //Hide the keypad when we pressed return
{
    CGPoint offset;
    offset=CGPointMake(0, 0);
    [self.ScrollProfile setContentOffset:offset animated:YES];

    [textField resignFirstResponder];
    return YES;
}

@end
