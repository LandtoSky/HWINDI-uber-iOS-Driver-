//
//  RegisterVC.h
//  Hwindi Driver
//
//  Created by Adam on 15/01/16.
//  Copyright (c) 2016 Hwindi. All rights reserved.
//

#import "BaseVC.h"
#import <Google/SignIn.h>
//#import "DLRadioButton.h"

@interface RegisterVC : BaseVC <UITextFieldDelegate, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GIDSignInUIDelegate, GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectVehicle;
@property (weak, nonatomic) IBOutlet UIView *viewSelectVehicle;
@property (weak, nonatomic) IBOutlet UICollectionView *typeCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;

@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;

@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPostalCode;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtTaxiModel;
@property (weak, nonatomic) IBOutlet UITextField *txtTaxiNumber;

@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckAgree;
@property (weak, nonatomic) IBOutlet UIButton *btnTermsConditions;

@property (strong, nonatomic) NSString *strPhoneNumber;
@property (strong, nonatomic) NSString *strCountryCode;
@end
