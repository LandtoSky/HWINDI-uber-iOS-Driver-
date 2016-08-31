//
//  VerificationViewController.h
//  HWINDI DRIVER
//
//  Created by Star Developer on 1/19/16.
//  Copyright © 2016 Deep Gami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "CountryPicker.h"

@interface VerificationViewController : BaseVC<CountryPickerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnRequestCode;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet CountryPicker *countryPicker;
@property (weak, nonatomic) IBOutlet UIView *viewRequest;

@property (weak, nonatomic) IBOutlet UIView *viewVerification;
@property (weak, nonatomic) IBOutlet UITextField *txtVerificationCode;
@property (weak, nonatomic) IBOutlet UIButton *btnVerify;

@end
