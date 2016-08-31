//
//  ForgotPasswordVC.h
//  UberforX Provider
//
//  Created by Adam on 12/25/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

#import "BaseVC.h"

@interface ForgotPasswordVC : BaseVC<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)btnSendPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@end
