//
//  BaseVC.m
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"
#import "PickMeUpMapVC.h"
#import "ArrivedMapVC.h"
#import "FeedBackVC.h"


@interface BaseVC ()

@end

@implementation BaseVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    animPop=YES;
    
    //Used height 44 image for showing the original status bar.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
}

#pragma mark -
#pragma mark - Utility Methods

-(void)setNavBarTitle:(NSString *)title
{
    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-60.0, 30)];
    UIFont* customFont = [UIFont fontWithName:@"OpenSans-Bold" size:12.0f];
    [lbl setFont:customFont];
    lbl.textAlignment=NSTextAlignmentLeft;
    lbl.textColor=[UIColor whiteColor];
    lbl.text=title;
    self.navigationItem.titleView=lbl;
}

-(void)setBackBarItem
{
    self.navigationItem.hidesBackButton = YES;

    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.frame=CGRectMake(0, 0, 18, 22);
    [btnLeft addTarget:self action:@selector(onClickBackBarItem:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
}

 
-(void)setBackBarItem:(BOOL)animated
{
    animPop=animated;
    [self setBackBarItem];
}

-(void)onClickBackBarItem:(id)sender
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
    if (obj==nil)
    {
        [self.navigationController popViewControllerAnimated:animPop];
    }
    else
    {
        [self.navigationController popToViewController:obj animated:animPop];
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
