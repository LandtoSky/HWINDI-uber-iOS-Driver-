//
//  PickMeUpMapVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import "sbMapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "LDProgressView.h"
#import "UIColor+RGBValues.h"
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "AudioToolbox/AudioToolbox.h"

@class SideBarVC;
@class ArrivedMapVC,RatingBar;


@interface PickMeUpMapVC : BaseVC <MKAnnotation,MKMapViewDelegate,GMSMapViewDelegate, AVAudioPlayerDelegate>
{
    UIImageView* routeView;
	NSArray* routes;
	
	UIColor* lineColor;
    LDProgressView *progressView;
    GMSMarker *marker;
}

//@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIView *etaView;
@property (weak, nonatomic) IBOutlet UIView *datePicker;

- (IBAction)onClickSetEta:(id)sender;
- (IBAction)onClickReject:(id)sender;
- (IBAction)onClickAccept:(id)sender;

- (IBAction)onClickNoKey:(id)sender;
-(void)goToSetting:(NSString *)str;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;


@property (weak, nonatomic) IBOutlet UIView *ProfileView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;

@property (strong, nonatomic) IBOutlet GMSMapView *mapView_;

@property (weak, nonatomic) IBOutlet UIProgressView *progressTimer;

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *progtime;
@property (weak, nonatomic) IBOutlet UIImageView *imgTimeBg;

@property (weak, nonatomic) IBOutlet UILabel *lblWhite;
@property(nonatomic, strong) ArrivedMapVC *arrivedMap;

@property (weak, nonatomic) IBOutlet RatingBar *ratingView;
@property (weak, nonatomic) IBOutlet UIView *viewForMap;
@property (weak, nonatomic) IBOutlet UIView *viewForNotApproved;
- (IBAction)onClickClose:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblNotApproved;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (strong, nonatomic) AVAudioPlayer *sound1Player;

@end
