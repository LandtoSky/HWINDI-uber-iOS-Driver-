//
//  TermsVC.m
//
//  Created by My Mac on 12/5/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "TermsVC.h"

@interface TermsVC ()

@end

@implementation TermsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackBarItem];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setNavBarTitle:NSLocalizedString(@"Terms & Conditions", nil)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnOKPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
