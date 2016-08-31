//
//  LoginVC.m
//  UberNewDriver
//
//  Created by Adam on 25/12/15.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "LoginVC.h"
#import "UIImageView+Download.h"
#import "AppDelegate.h"
#import "RegisterVC.h"

@interface LoginVC ()
{
    NSMutableDictionary *dictparam;
    
    NSString * strEmail;
    NSString * strPassword;

    NSString * strLoginType;
    NSString * strSocialId;
}

@end

@implementation LoginVC

@synthesize txtPassword,txtEmail;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBarTitle:@"Sign In Using"];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    //[GIDSignIn sharedInstance].allowsSignInWithWebView = YES;
    //[GIDSignIn sharedInstance].allowsSignInWithBrowser = YES;
    
    [self localizeString];
    [self customFont];
    
    dictparam=[[NSMutableDictionary alloc] init];
    
    //Reset NSUserDefaults for this app.
    //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //Once the user logged in, Go to Pickme directly.
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strEmail = [pref objectForKey:PREF_EMAIL];
    strPassword = [pref objectForKey:PREF_PASSWORD];
    strSocialId = [pref objectForKey:PREF_SOCIAL_ID];
    strLoginType = [pref objectForKey:PREF_LOGIN_BY];
    device_token = [pref objectForKey:PREF_DEVICE_TOKEN];
    
    BOOL isLoggedIn=[pref boolForKey:PREF_IS_LOGIN];
    if(isLoggedIn){
        [self getSignIn];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
}
-(void)localizeString
{
    NSAttributedString *email = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtEmail.attributedPlaceholder = email;
    NSAttributedString *password = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.txtPassword.attributedPlaceholder = password;
}
-(void)customFont
{
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPassword.font=[UberStyleGuide fontRegular];
    
    self.btnForgotPassword.titleLabel.font = [UberStyleGuide fontRegular];
    self.btnSignIn.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnSignUp.titleLabel.font = [UberStyleGuide fontRegularBold];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sign In
-(void)getSignIn
{
    if(strEmail == nil)
        return;
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"LOADING", nil)];
    
    [dictparam setObject:device_token forKey:PARAM_DEVICE_TOKEN];
    [dictparam setObject:@"ios" forKey:PARAM_DEVICE_TYPE];
    [dictparam setObject:strEmail forKey:PARAM_EMAIL];
    [dictparam setObject:strLoginType forKey:PARAM_LOGIN_BY];
    if (![strLoginType isEqualToString:@"manual"])
    {
        [dictparam setObject:strSocialId forKey:PARAM_SOCIAL_ID];
    }
    else
    {
        [dictparam setObject:strPassword forKey:PARAM_PASSWORD];
    }
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_LOGIN withParamData:dictparam withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 arrUser=response;
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 [pref setObject:[response valueForKey:PARAM_TOKEN] forKey:PREF_USER_TOKEN];
                 [pref setObject:[response valueForKey:PARAM_ID] forKey:PREF_USER_ID];
                 [pref setObject:[response valueForKey:PARAM_DEVICE_TOKEN] forKey:PREF_DEVICE_TOKEN];
                 [pref setObject:[response  valueForKey:PARAM_SOCIAL_ID] forKey:PREF_SOCIAL_ID];
                 
                 [pref setObject:strEmail forKey:PREF_EMAIL];
                 [pref setObject:strPassword forKey:PREF_PASSWORD];
                 [pref setObject:strLoginType forKey:PREF_LOGIN_BY];
                 [pref setBool:YES forKey:PREF_IS_LOGIN];
                 
                 [pref setObject:[response valueForKey:PREF_IS_APPROVED] forKey:PREF_IS_APPROVED];
                 [pref synchronize];
                 
                 [APPDELEGATE showToastMessage:(NSLocalizedString(@"SIGNIN_SUCCESS", nil))];
                 [self performSegueWithIdentifier:@"seguetopickme" sender:self];
             }
             else
             {
                 [APPDELEGATE showAlert:NSLocalizedString(@"SIGNIN_FAILED", nil)];
             }
         }
     }];
}

#pragma mark -
#pragma mark - Button Action

- (IBAction)onClickSignIn:(id)sender
{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    if(self.txtEmail.text.length==0)
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_EMAIL", nil)];
        return;
    }
    else if(self.txtPassword.text.length == 0 )
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_PASSWORD", nil)];
        return;
    }
    if(![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text]){
        [APPDELEGATE showAlert:NSLocalizedString(@"PLEASE_VALID_EMAIL", nil)];
        return;
    }
    
    strEmail=self.txtEmail.text;
    strPassword=self.txtPassword.text;
    strLoginType=@"manual";

    [self getSignIn];
}

- (IBAction)onClickCreateAccount:(id)sender {
    
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
        strEmail = user.profile.email;
        strLoginType=@"google";
        strSocialId = user.userID;
        [self getSignIn];
        
    }
    
}
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error != nil) {
        // There was an error obtaining the Google OAuth token, display a dialog
        NSString *message = [NSString stringWithFormat:@"There was an error logging into Google: %@",
                             [error localizedDescription]];
        [APPDELEGATE showAlert:message];
    }
}
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    if (error != nil) {
        // There was an error obtaining the Google OAuth token, display a dialog
        NSString *message = [NSString stringWithFormat:@"There was an error logging into Google: %@",
                             [error localizedDescription]];
        [APPDELEGATE showAlert:message];
    }
}
#pragma mark - Click Event
- (IBAction)onClickGoogle:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"No Internet", nil)];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
}


- (IBAction)onClickFacebook:(id)sender
{
    if(![APPDELEGATE connected]){
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
//    [APPDELEGATE showLoadingWithTitle:@"Please wait"];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Facebook login failed. Error: %@", error);
        } else if (result.isCancelled) {
            NSLog(@"Facebook login got cancelled.");
        } else{ //Success
            NSLog(@"Success");
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog(@"Failed fetching user information.");
                } else {
                    strEmail=[result objectForKey:PREF_EMAIL];
                    strLoginType=@"facebook";
                    strSocialId=[result objectForKey:PREF_USER_ID];
                    
                    [self getSignIn];
                }
            }];
        }
    }];
}
- (IBAction)onclickForgotPassword:(id)sender
{
    
}
#pragma mark- Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(textField==self.txtEmail)
        [self.txtPassword becomeFirstResponder];
   
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation
  // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"seguetopickme"])
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
}
 

@end
