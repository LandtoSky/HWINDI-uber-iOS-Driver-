//
//  VerificationViewController.m
//  HWINDI DRIVER
//
//  Created by Star Developer on 1/19/16.
//  Copyright © 2016 Deep Gami. All rights reserved.
//

#import "VerificationViewController.h"
#import "RegisterVC.h"

@interface VerificationViewController (){
    UIVisualEffectView *blurEffectView;
    UIView *coverView;
}

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackBarItem];
    [self setNavBarTitle:NSLocalizedString(@"SMS Verification", nil)];
    
    [self customFont];
    [self localizeString];
    [self.countryPicker setHidden:YES];
    [self.viewVerification setHidden:YES];
    
    [self.viewVerification.layer setCornerRadius:10.0f];
    [self.viewVerification.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.viewVerification.layer setBorderWidth:1.0f];
    
    //For country calling code.
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSMutableArray *arrCountry = [[NSMutableArray alloc] init];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    arrCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", countryCode];
    NSArray *results = [arrCountry filteredArrayUsingPredicate:predicate];
    NSArray *code = [results valueForKey:@"phone-code"];
    [self.btnCountryCode setTitle:code[0] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)customFont
{
    self.txtDescription.font=[UberStyleGuide fontRegular];
    self.txtPhoneNumber.font=[UberStyleGuide fontRegular];
    self.txtVerificationCode.font = [UberStyleGuide fontRegular];
    
    self.btnCountryCode.titleLabel.font = [UberStyleGuide fontRegular];
    self.btnRequestCode.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnVerify.titleLabel.font = [UberStyleGuide fontRegularBold];
}
-(void) countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    [self.countryPicker setHidden:YES];
    
    NSMutableArray *arrCountry = [[NSMutableArray alloc] init];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    arrCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", code];
    NSArray *results = [arrCountry filteredArrayUsingPredicate:predicate];
    NSArray *pcode = [results valueForKey:@"phone-code"];
    [self.btnCountryCode setTitle:pcode[0] forState:UIControlStateNormal];
}
- (IBAction)onClickCountryCode:(id)sender {
    //[self.countryPicker setHidden:NO];
}
- (IBAction)onClickRequestCode:(id)sender {
    if(self.txtPhoneNumber.text.length<1)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER", nil)];
        return;
    }
    else if(self.txtPhoneNumber.text.length<10)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_NUMBER_MIN", nil)];
        return;
    }
    
    /*UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.viewRequest addSubview:blurEffectView];*/
    
    if(coverView==nil){
        coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.viewRequest addSubview:coverView];
    
    [self.viewVerification setHidden:NO];
    /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please enter verification code." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Verify" style:UIAlertActionStyleDefault handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [self presentViewController:alert animated:YES completion:nil];*/
}
- (IBAction)onClickVerify:(id)sender {
    //[blurEffectView removeFromSuperview];
    [coverView removeFromSuperview];
    [self.viewVerification setHidden:YES];
    
    //TODO, Verification code check.
    
    if([self.txtVerificationCode.text isEqualToString:@"55555"]){
        //[APPDELEGATE showAlert:@"Verified"];
        [self performSegueWithIdentifier:@"segueToRegister" sender:self];
    } else {
        [APPDELEGATE showAlert:@"Verification failed."];
    }
}
-(void)localizeString
{
   
    NSAttributedString *phone = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PHONE", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPhoneNumber.attributedPlaceholder = phone;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueToRegister"])
    {
        RegisterVC *registerVC = segue.destinationViewController;
        registerVC.strPhoneNumber = self.txtPhoneNumber.text;
        registerVC.strCountryCode = self.btnCountryCode.titleLabel.text;
    }
}


@end
