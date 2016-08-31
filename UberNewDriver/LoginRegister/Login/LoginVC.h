//
//  LoginVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import <Google/SignIn.h>

@interface LoginVC : BaseVC <UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate>

- (IBAction)onClickSignIn:(id)sender;
- (IBAction)onClickGoogle:(id)sender;
- (IBAction)onClickFacebook:(id)sender;
- (IBAction)onclickForgotPassword:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property(nonatomic,weak)IBOutlet UIScrollView *scrLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;


@end
