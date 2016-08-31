//
//  PickMeUpMapVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "PickMeUpMapVC.h"
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "ContactVC.h"
#import "ArrivedMapVC.h"
#import "RatingBar.h"
#import "UIView+Utils.h"

@interface PickMeUpMapVC ()
{
   
    NSMutableArray *arrRequest;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    NSMutableDictionary *dict;
    NSMutableDictionary *dictOwner;
    BOOL flag,isTo,is_approved;
    int time;
    float totalDist;
}

@end

@implementation PickMeUpMapVC
@dynamic coordinate;
@synthesize mapView_;
@synthesize lblTime,btnProfile, lblName, ProfileView,imgUserProfile,sound1Player;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBarTitle:@"Hwindi"];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [APPDELEGATE startLocationUpdate];
    } else {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Hwindi Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
    [self hide];
    [self localizeString];
    [self customFont];

    self.arrivedMap.pickMeUp=self;
    [self.imgUserProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    
    isTo=NO;
    time=0;
    progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-50,-50, 320,20)];
    progressView.color = [UIColor colorWithRed:0.0f/255.0f green:193.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    //progressView.background = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0];
    progressView.progress = 1.0;
    progressView.showText = @NO;
    progressView.animate = @NO;
    progressView.borderRadius = @NO;
    [self.ProfileView addSubview:progressView];
    [self.ProfileView bringSubviewToFront:self.lblTime];
    
    self.etaView.hidden=YES;
    
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    is_approved=[[pref valueForKey:PREF_IS_APPROVED] boolValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:NOTIFICATION_LOCATION_UPDATE object:nil];

    [self getPagesData];

    mapView_.myLocationEnabled = NO;
    mapView_.delegate=self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (is_approved)
    {
        self.viewForNotApproved.hidden=YES;
        [self setMenuBarItem];
    }
    else
    {
        self.viewForNotApproved.hidden=NO;
    }
   
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    //
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showUserLocation) userInfo:nil repeats:NO];
    [self getRequestId];
    
    strowner_lati=nil;
    strowner_longi=nil;

    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current.latitude
                                                            longitude:current.longitude
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewForMap.frame.size.width, self.viewForMap.frame.size.height) camera:camera];
    
    [self.viewForMap addSubview:mapView_];

    self.navigationItem.hidesBackButton=YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapView_ clear];
    [APPDELEGATE stopLocationUpdate];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setMenuBarItem
{
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *btnMenu=[UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame=CGRectMake(0, 0, 18, 22);
    [btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    [btnMenu setTitle:NSLocalizedString(@"MENU", nil) forState:UIControlStateNormal];
    [btnMenu setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}

-(void)showUserLocation
{
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=[struser_lati doubleValue];
    coordinate.longitude=[struser_longi doubleValue];
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
    [mapView_ animateWithCameraUpdate:updatedCamera];
    
    if(marker==nil){
        marker = [[GMSMarker alloc] init];
    }
    marker.position = coordinate;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"marker_location"];
    marker.map = mapView_;
    
}


#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.btnAccept.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnReject.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnClose.titleLabel.font = [UberStyleGuide fontRegularBold];

    self.lblName.font=[UberStyleGuide fontRegular];
}
-(void)localizeString
{
    [self.btnAccept setTitle:NSLocalizedString(@"ACCEPT",nil)forState:UIControlStateNormal];
    [self.btnReject setTitle:NSLocalizedString(@"REJECT",nil)forState:UIControlStateNormal];
    [self.btnClose setTitle:NSLocalizedString(@"CLOSE",nil)forState:UIControlStateNormal];
}

#pragma mark-
#pragma mark- Profile View Hide/Show Method

-(void)hide
{
    self.lblTime.hidden=YES;
    self.lblWhite.hidden=YES;
    self.imgTimeBg.hidden=YES;
    [ProfileView setHidden:YES];
    [self.btnAccept setHidden:YES];
    [self.btnReject setHidden:YES];
}

-(void)show
{
    self.lblTime.hidden=NO;
    self.lblWhite.hidden=NO;
    self.imgTimeBg.hidden=NO;
    [ProfileView setHidden:NO];
    [self.btnAccept setHidden:NO];
    [self.btnReject setHidden:NO];
    
}

#pragma mark-
#pragma mark- If-Else Methods

-(void)getRequestId
{
    if (strRequsetId!=nil)
    {
        [self checkRequest];
    }
    else
    {
        [self requestInProgress];
        
    }
}

#pragma mark-
#pragma mark- API Methods

-(void)checkRequest
{
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    
    [dictparam setObject:strUserId forKey:PARAM_ID];
    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
    [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
     {

         if([[response valueForKey:@"success"] intValue]==1)
         {
             NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
             
             is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
             is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
             is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
             is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
             is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
             
             
             dictOwner=[dictRequest valueForKey:@"owner"];;//[arrOwner objectAtIndex:0];
             strowner_lati=[dictOwner valueForKey:@"latitude"];
             strowner_longi=[dictOwner valueForKey:@"longitude"];
             payment=(int)[[dictRequest valueForKey:@"payment_type"] integerValue];
             
             
             NSString *gmtDateString = [dictRequest valueForKey:@"start_time"];
             NSDateFormatter *df = [NSDateFormatter new];
             [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
             NSDate *datee = [df dateFromString:gmtDateString];
             df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
             
             NSString *startTime=[NSString stringWithFormat:@"%f",[datee timeIntervalSince1970] * 1000];
             
             NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
             [pref setObject:startTime forKey:PREF_START_TIME];
             [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
             [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
             [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
             [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
             [pref synchronize];
             [mapView_ clear];
             
             [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
             [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
             
             
         }
     }];
    
}


-(void)requestInProgress
{
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    
    [dictparam setObject:strUserId forKey:PARAM_ID];
    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_PROGRESS withParamData:dictparam withBlock:^(id response, NSError *error)
    {

        if([[response valueForKey:@"success"]intValue]==1)
        {
            
            if ([[response valueForKey:@"request_id"] intValue]!=-1)
            {
                strRequsetId=[response valueForKey:@"request_id"];
                NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                [pref setObject:strRequsetId forKey:PREF_REQUEST_ID];
                [pref synchronize];
                [self checkRequest];
            } else {
                [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
                //[self getAllRequests];
            }
        }

    }];
}

-(void)getAllRequests
{
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId = [pref valueForKey:PARAM_ID];
    strUserToken = [pref valueForKey:PARAM_TOKEN];
    [pref synchronize];
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    
    [dictparam setObject:strUserId forKey:PARAM_ID];
    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
     {

         if([[response valueForKey:@"success"] intValue]==1)
         {
             
             NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
             is_approved=[[response valueForKey:@"is_approved"] boolValue];
             [pref setBool:is_approved forKey:PREF_IS_APPROVED];
             
             if (is_approved)
             {
                 self.viewForNotApproved.hidden=YES;
             }
             else
             {
                 self.viewForNotApproved.hidden=NO;
             }
             
             NSMutableArray *arrRespone=[response valueForKey:@"incoming_requests"];
             if(arrRespone.count!=0)
             {
                 
                 [self.timer invalidate];
                 NSMutableDictionary *dictRequestData=[arrRespone valueForKey:@"request_data"];
                 NSMutableArray *arrOwner=[dictRequestData valueForKey:@"owner"];
                 dictOwner=[arrOwner objectAtIndex:0];
                 
                 NSMutableArray *arrRequest_Id=[arrRespone valueForKey:@"request_id"];
                 strRequsetId=[NSMutableString stringWithFormat:@"%@",[arrRequest_Id objectAtIndex:0]];
                 
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 [pref setObject:strRequsetId forKey:PREF_REQUEST_ID];
                 [pref synchronize];
                 
                 lblName.text=[dictOwner valueForKey:@"name"];

                 [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                 strowner_lati=[dictOwner valueForKey:@"latitude"];
                 strowner_longi=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"longitude"]];
                 RBRatings rate=([[dictOwner valueForKey:@"rating"]floatValue]*2);
                 [ self.ratingView setRatings:rate];
                 
                 payment=(int)[[dictOwner valueForKey:@"payment_type"] integerValue];
                 
                 [self.mapView_ clear];
                 
                 CLLocationCoordinate2D current;
                 current.latitude=[struser_lati doubleValue];
                 current.longitude=[struser_longi doubleValue];
                 
                 marker = [[GMSMarker alloc] init];
                 marker.position = current;
                 marker.appearAnimation = kGMSMarkerAnimationPop;
                 marker.icon = [UIImage imageNamed:@"marker_source"];
                 marker.map = mapView_;
                 
                 CLLocationCoordinate2D currentOwner;
                 currentOwner.latitude=[strowner_lati doubleValue];
                 currentOwner.longitude=[strowner_longi doubleValue];
                 
                 
                 GMSMarker *markerPassenger = [[GMSMarker alloc] init];
                 markerPassenger.position = currentOwner;
                 markerPassenger.appearAnimation = kGMSMarkerAnimationPop;
                 markerPassenger.icon = [UIImage imageNamed:@"pin_client_org"];
                 markerPassenger.map = mapView_;
                 
                 NSMutableArray *arrTime=[arrRespone valueForKey:@"time_left_to_respond"];
                 time=[[arrTime objectAtIndex:0]intValue];
                 
                 
                 [self.progtime invalidate];
                 NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                 self.progtime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(customProgressBar) userInfo:nil repeats:YES];
                 [runloop addTimer:self.progtime forMode:NSRunLoopCommonModes];
                 [runloop addTimer:self.progtime forMode:UITrackingRunLoopMode];
                 
                 
                 [self show];
                 [self centerMapFirst:current two:currentOwner third:current];
                 
             }
             
         }
         
         
     }];
    
}

-(void)locationUpdated:(NSNotification*) notification
{
    if(![APPDELEGATE connected])
    {
        return;
    }
    
    if(((struser_lati==nil)&&(struser_longi==nil))
       ||(([struser_longi doubleValue]==0.00)&&([struser_lati doubleValue]==0)))
    {
        return;
    }

    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId = [pref valueForKey:PARAM_ID];
    strUserToken = [pref valueForKey:PARAM_TOKEN];
    [pref synchronize];
    
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    [dictparam setObject:strUserId forKey:PARAM_ID];
    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
    [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
    [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_USERLOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 
             }
         }
         
     }];

}

-(void)respondToRequset
{
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"NO_INTERNET", nil)];
        return;
    }
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    if (strRequsetId!=nil)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:@"1" forKey:PARAM_ACCEPTED];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Respond to Request= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_ACCEPTED", nil)];
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     
                     [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
                     [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
                     [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
                     [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
                     [pref synchronize];
                     
                     
                     lblName.text=[dictOwner valueForKey:@"name"];
                     [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                     
                     [self.timer invalidate];
                     [self.progtime invalidate];
                     [self hide];
                     
                     [mapView_ clear];
                     [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                 }
             }
             
         }];
    }
    else
    {
        
    }

}


-(void)getPagesData
{
    if(![APPDELEGATE connected])
    {
        [APPDELEGATE showAlert:NSLocalizedString(@"No Internet", nil)];
        return;
    }
    
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGES,PARAM_ID,strUserId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 arrPage=[response valueForKey:@"informations"];
             }
         }
         
     }];

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -
#pragma mark - Draw Route Methods

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    
    
    
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    
    region.span.latitudeDelta = 1.5;
    region.span.longitudeDelta = 1.5;
    
    //[self.mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
}

-(void)centerMapFirst:(CLLocationCoordinate2D)pos1 two:(CLLocationCoordinate2D)pos2 third:(CLLocationCoordinate2D)pos3
{
    GMSCoordinateBounds* bounds =
    [[GMSCoordinateBounds alloc]initWithCoordinate:pos1 coordinate:pos2];
    bounds = [bounds includingCoordinate:pos3];
    
    CLLocationCoordinate2D location1 = bounds.southWest;
    CLLocationCoordinate2D location2 = bounds.northEast;
    
    float mapViewWidth = mapView_.frame.size.width;
    float mapViewHeight = mapView_.frame.size.height;
    
    MKMapPoint point1 = MKMapPointForCoordinate(location1);
    MKMapPoint point2 = MKMapPointForCoordinate(location2);
    
    MKMapPoint centrePoint = MKMapPointMake(
                                            (point1.x + point2.x) / 2,
                                            (point1.y + point2.y) / 2);
    CLLocationCoordinate2D centreLocation = MKCoordinateForMapPoint(centrePoint);
    
    double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
    double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
    double mapScale = MIN(mapScaleWidth, mapScaleHeight);
    
    double zoomLevel = 19.1 + log2(mapScale);
    
    //    GMSCameraPosition *camera = [GMSCameraPosition
    //                                 cameraWithLatitude: centreLocation.latitude
    //                                 longitude: centreLocation.longitude
    //                                 zoom: zoomLevel];
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:centreLocation zoom: zoomLevel];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
}


//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
-(void) showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t

{
    if(routes)
    {
        //[self.mapView removeAnnotations:[self.mapView annotations]];
        [mapView_ clear];
    }

    GMSMarker *markerPassenger = [[GMSMarker alloc] init];
    markerPassenger.position = f;
    markerPassenger.appearAnimation = kGMSMarkerAnimationPop;
    markerPassenger.icon = [UIImage imageNamed:@"pin_client_org"];
    markerPassenger.map = mapView_;
    
    GMSMarker *markerDriver = [[GMSMarker alloc] init];
    markerDriver.position = f;
    markerDriver.icon = [UIImage imageNamed:@"marker_source"];
    markerDriver.appearAnimation = kGMSMarkerAnimationPop;
    markerDriver.map = mapView_;
    
    routes = [self calculateRoutesFrom:f to:t];
    NSInteger numberOfSteps = routes.count;
    
    
    GMSMutablePath *pathpoliline=[GMSMutablePath path];
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [routes objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        [pathpoliline addCoordinate:coordinate];
    }
 
    
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathpoliline];
    
    polyLinePath.strokeColor = [UIColor blueColor];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.geodesic = YES;
    polyLinePath.map = mapView_;
    [self centerMap];
}


#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    
    
}



#pragma mark-
#pragma mark- Button Click Events

- (IBAction)onClickSetEta:(id)sender
{
    
    
}

- (IBAction)onClickReject:(id)sender
{
    if ([APPDELEGATE connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
        
        if (strRequsetId!=nil)
        {
            NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
            
            [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
            [dictparam setObject:strUserId forKey:PARAM_ID];
            [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
            [dictparam setObject:@"0" forKey:PARAM_ACCEPTED];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
             {
                 
                 NSLog(@"Respond to Request= %@",response);
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_REJECTED", nil)];
                         
                         //[self.time invalidate];
                         [self.progtime invalidate];
                         [self hide];
                         NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                         self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
                         [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
                         [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
                     }
                 }
                 
             }];
        }
        else
        {
            
        }
    }
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_REQUEST_ID];
    strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
  
    [mapView_ clear];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"marker_source"];
    marker.map = mapView_;

    [self.progtime invalidate];
    [self hide];
}

- (IBAction)onClickAccept:(id)sender
{
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_ADMIN_APPROVE", nil)];
    [self respondToRequset];
    //[self performSegueWithIdentifier:@"segurtoarrived" sender:self];
    
    //[self.etaView setHidden:NO];
}

- (IBAction)onClickNoKey:(id)sender
{
    [self.etaView setHidden:YES];
}

- (IBAction)onClickShowMe:(id)sender
{
    [self showUserLocation];
}


-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

-(void)invalidateTimer
{
    [self.timer invalidate];
}



#pragma mark-
#pragma mark- Progress Bar Method

-(void)customProgressBar
{
    progressView.hidden=YES;
    float t=(time/60.0f);
    lblTime.text=[NSString stringWithFormat:@"%d",time];
    //self.lblTime.font=[UberStyleGuide fontRegular:48.0f];
    self.lblTime.font=[UIFont fontWithName:@"OpenSans" size:48.0f];
    if(time<5)
    {
        progressView.color = [UIColor colorWithRed:245.0f/255.0f green:25.0f/255.0f blue:42.0f/255.0f alpha:1.0];
    }
    else
    {
        progressView.color = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:214.0f/255.0f alpha:1.0];
    }
    
    
    progressView.background = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0];
    progressView.showText = @NO;
    progressView.progress = t;
    progressView.borderRadius = @NO;
    progressView.animate = @NO;
    progressView.type = LDProgressSolid;
    time=time-1;
    if(time<15)
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        if ([[pref valueForKey:@"SOUND"] isEqualToString:@"on"]) {
            [self PlaySound];
            [sound1Player play];
        }
    }
    if(time<0)
    {
        [self.progtime invalidate];
        [self hide];
        [sound1Player stop];
        
        [self.timer invalidate];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref removeObjectForKey:PREF_REQUEST_ID];
        strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
        
        
        [self getAllRequests];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
        [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
        [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
        
        [mapView_ clear];
        
        CLLocationCoordinate2D current;
        current.latitude=[struser_lati doubleValue];
        current.longitude=[struser_longi doubleValue];
        
        
        marker = [[GMSMarker alloc] init];
        marker.position = current;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [UIImage imageNamed:@"marker_source"];
        marker.map = mapView_;
    }
    
}

#pragma mark-
#pragma mark - Sound Player
-(void)PlaySound
{
    
    [sound1Player stop];
    
    NSString *bk=[NSString stringWithFormat:@"beep-07"];
    NSString *path = [[NSBundle mainBundle] pathForResource:bk ofType:@"mp3"];
    NSURL *url=[NSURL fileURLWithPath:path];
    
    sound1Player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    if(!sound1Player)
    {
        NSLog(@"error");
    }
    
    sound1Player.delegate=self;
    sound1Player.numberOfLoops=0;
    [sound1Player stop];
}

#pragma mark-
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"contact us"])
    {
        ContactVC *obj=[segue destinationViewController];
        obj.dictContact=sender;
    }
    
}

- (IBAction)onClickClose:(id)sender
{
   exit(0);
    //[self performSegueWithIdentifier:@"segueToMain" sender:nil];

}

@end
