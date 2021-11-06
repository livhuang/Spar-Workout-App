//
//  RunningViewController.m
//  Spår
//
//  Created by Nassir Ali on 5/5/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "RunningViewController.h"
#import "MapKit/MapKit.h"
@import Firebase;

@interface RunningViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *pauseLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//CLLocation for the run's beginning and end
@property (nonatomic) CLLocation *beginningLocation;
@property NSMutableArray<CLLocation *> *locationHistory;

@property (nonatomic) CLLocation *lastLocation;
@property (nonatomic) CLLocationDistance traveledDistance;

@property (nonatomic) NSTimer *runTimer;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *saveRunButton;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *pauseTime;
@property (nonatomic) int timerCounter;
@property (nonatomic) bool timerIsPaused;
@property (nonatomic) bool timerIsRunning;


@end

@implementation RunningViewController{
    NSDictionary *dict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //label set-up
    _startLabel.layer.cornerRadius = 10;
    [_startLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_startLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_startLabel.layer setShadowOpacity:0.5];
    
    _stopLabel.layer.cornerRadius = 10;
    [_stopLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_stopLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_stopLabel.layer setShadowOpacity:0.5];
    
    _pauseLabel.layer.cornerRadius = 10;
    [_pauseLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_pauseLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_pauseLabel.layer setShadowOpacity:0.5];
    
    //hide the pause and stop buttons
    _pauseButton.hidden = true;
    _stopButton.hidden = true;
    _saveRunButton.hidden = true;
    
    _timerIsPaused = false; //because user has not started the timer yet, therefore the first time hit startbutton is to begin the timer
    _timerIsRunning = false;
    _timeLabel.text = @"00:00.00";
    
    //allocate _locationHistory NSMutableArray
    _locationHistory =[[NSMutableArray alloc]init];
    
    //CHECK IF THE USER'S LOCATION SERVICES ARE ON
    //if location services are on,
    if([self checkLocationServices] == true){
        
        NSLog(@"Location services are on");
        //setUpLocationManager
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;

        _mapView.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;

        
        NSLog(@"latitude: %lf longitude %lf", locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
        
        //check location authorization status
        if ([self checkLocationAuthorization]){
            _mapView.showsUserLocation = true;
            NSLog(@"Map shows user location.");
            [self centerViewOnUserLocation];
            NSLog(@"startUpdatingLocation method has been called");
        }else{
            NSLog(@"Your device has denied location authorization for this app. ");
        }
    
    
    //else, location services are off
    }else{
        //tell user they need to turn location services on in an alert
        NSLog(@"Location services are not on");
    }
    
    [self configureDatabase];
    
}

- (void)configureDatabase {
    _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
    
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"latitude: %lf longitude %lf", locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
}



//------------------------------------------        BUTTON METHODS      ------------------------------------------
- (IBAction)startButtonPressed:(id)sender {
   
    //HANDLE BUTTONS AND LABELS
    if(_pauseButton.isHidden && _stopButton.isHidden){
        _startButton.hidden = true;
        _startLabel.hidden = true;
        
        _pauseButton.hidden = false;
        _pauseLabel.hidden = false;
        
        _backButton.hidden = true;
    }
    
    else if(_pauseButton.isHidden && !_stopButton.isHidden){
        _startButton.hidden = true;
        _startLabel.hidden = true;
        
        _stopButton.hidden = true;
        _stopLabel.hidden = true;
        
        _pauseButton.hidden = false;
        _pauseLabel.hidden = false;
    }
    
    //MANIPULATING TIMER
    if (!_timerIsRunning){
        _timerIsPaused = false;
        _startTime = [NSDate date];
        if (_runTimer == nil){
            _runTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        }
        
        _timerIsRunning = !_timerIsRunning;
        
    //else resume timer
    }else{
        NSTimeInterval secondsBetween = [_pauseTime timeIntervalSinceDate:_startTime];
        _startTime = [NSDate dateWithTimeIntervalSinceNow:(-1)*secondsBetween];
        
        if (_runTimer==nil){
            _runTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                                  target:self
                                                                selector:@selector(updateTimer)
                                                                userInfo:nil
                                                                 repeats:YES];
        }
        _timerIsPaused = !_timerIsPaused;
    }
    //un-hide pause and stop buttons, hide start button
    _startButton.hidden = true;
    _pauseButton.hidden = false;
    _stopButton.hidden = true;
    [locationManager startUpdatingLocation];
}

- (IBAction)pauseButtonPressed:(id)sender {
    //HANDLE BUTTONS
    _startButton.hidden = false;
    _startLabel.hidden = false;
    
    _stopButton.hidden = false;
    _stopLabel.hidden = false;
    
    _pauseButton.hidden = true;
    _pauseLabel.hidden = true;
    
        
    //pause timer
    if (!_timerIsPaused){
        [_runTimer invalidate];
        _runTimer = nil;
        _pauseTime = [NSDate date];
    }
    _timerIsPaused = !_timerIsPaused;
    
    [locationManager stopUpdatingLocation];
}

- (IBAction)stopButtonPressed:(id)sender {
    _saveRunButton.hidden = false;
    _backButton.hidden = false;
    [_runTimer invalidate];
    _runTimer = nil;

    [locationManager stopUpdatingLocation];
    
    CLLocationDistance distance = [_beginningLocation distanceFromLocation:_locationHistory.lastObject];
    
    NSLog(@"The number of locationHistory objects %lu", (unsigned long)_locationHistory.count);
    
    NSLog(@"The beginning location of locHist: %@", _beginningLocation);
    NSLog(@"The end location of locHist: %@", _locationHistory.lastObject);
    
    //WE DO NOT WANT STRAIGHT DISTANCE BECAUSE THIS IS THE DISTANCE IN A STRAIGHT LINE BETWEEN TWO CLLocation COORDINATES. This is why we calculated the traveledDistance
    NSLog(@"The total distance (STRAIGHT DISTANCE) in meters is: %f", distance);
    NSLog(@"The total distance (STRAIGHT DISTANCE) in miles is: %f", distance/1609);
    
    
    NSLog(@"Traveled Distance: %f", _traveledDistance);
    NSLog(@"The traveled distance in miles is: %f", _traveledDistance/1609);    //1609 meters in 1 mile
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSLog(@"%@", timestamp);
    dict = @{
        @"date": timestamp,
        //@"locationHistory": _locationHistory,
        @"distanceMeters": [NSString stringWithFormat:@"%f", distance],
        @"distanceMiles": [NSString stringWithFormat:@"%f", distance/1609],
        @"traveledDistance": [NSString stringWithFormat:@"%F", _traveledDistance]
    };
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveRun:(id)sender {
    NSMutableDictionary *mdata = [dict mutableCopy];
    int r = arc4random_uniform(9999999);
    NSString *randomIndex = [NSString stringWithFormat:@"%d", r ];
    [[[_ref child:@"runs"] child:randomIndex] setValue:mdata];
    [self InformativeAlertWithmsg:[NSString stringWithFormat:@"New run at %@", randomIndex]];
}

-(void)InformativeAlertWithmsg:(NSString *)msg
   {
     UIAlertController *alertvc=[UIAlertController alertControllerWithTitle:@"Successfully added workout!" message:msg preferredStyle:UIAlertControllerStyleAlert];
       UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                 style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
           [self dismissViewControllerAnimated:YES completion:nil];
                                   NSLog(@ "Dismiss Tapped");
                                 }
                                ];
       [alertvc addAction: action];
       [self presentViewController: alertvc animated: true completion: nil];
       
   }
- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)updateTimer{
    
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startTime];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    _timeLabel.text = timeString;
    
}



//------------------------------------------        LOCATION SERVICES METHODS      ------------------------------------------


- (bool) checkLocationServices{
    if (CLLocationManager.locationServicesEnabled){
        return true;
    }else{
        return false;
        //tell user they need to turn this on
    }
}



-(bool)checkLocationAuthorization{
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"User location authorized when in use.");
            return true;
            break;
        case kCLAuthorizationStatusDenied:
            
            NSLog(@"User location is denied.");
            //show alert telling user they need 2 go to settings and turn location services on (permissions)
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Authorization Status not determined (user hasn't decided yet).");
            //The app has never asked the User for Location permissions before, so request the authorization
            [locationManager requestWhenInUseAuthorization];
            NSLog(@"If this shows that means request should have been made.");
            return true;
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Authorization status restricted.");
            //show alert telling user that their location permissions are restricted
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"User location authorized always.");
            return true;
            break;
    }
    //if it reaches this, then authorization status is denied
    return false;
}


- (void) centerViewOnUserLocation{
    CLLocationCoordinate2D location = locationManager.location.coordinate;

    if (locationManager.location != nil){

        NSLog(@"user location != nil");
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        MKCoordinateSpan span;
        //= MKCoordinateSpanMake(500, 500);
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

        [_mapView setRegion:region animated:true];
    }
}





#pragma mark - CLLocationManagerDelegate


//if the location authorization changes
-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self checkLocationAuthorization];
}

//if location updates
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    //guard against there being no location
    if (locations.lastObject == nil) return;
    CLLocation *currentLocation = locations.lastObject;
    //handle first location object
    if(_beginningLocation == nil) _beginningLocation = locations.firstObject;
    
    else{
        /*UPDATING THE TRAVEL DISTANCE:
         Have to update the travel distance manually, as the didUpdateLocations function is updating, instead of using the CLLocationDistance distanceFromLocation function.
         This is because the distanceFromLocation function calculates the distance in a straight line in between the first and last CLLocation objects in the _locationHistory array  */
        
        _traveledDistance += [currentLocation distanceFromLocation:_lastLocation];
        NSLog(@"Traveled Distance: %f", _traveledDistance);
    }
    
    _lastLocation  = locations.lastObject;
    
    //update the location history by appending object
    [_locationHistory addObject:_lastLocation];
    
    NSLog(@"Location Updated: %f     %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude );
 
    double milesPerHour = currentLocation.speed * 2.236936;     //miles per hour = meters per second × 2.236936
    NSLog(@"Speed (this is where pace goes): %f     MILES PER HOUR: %f", currentLocation.speed, milesPerHour);
    
    //---------------     UPDATE LABELS     ----------
    
    //update pace label
    NSString* mphString = [NSString stringWithFormat:@"%.02f", milesPerHour];
    _paceLabel.text = mphString ;
    
    //convert travel distance from meters to miles, and update distance label
    NSString* travelDist = [NSString stringWithFormat:@"%.02f", _traveledDistance/1609];    //1609 meters in 1 mile
    _distanceLabel.text =[ NSString stringWithFormat:@"%@ miles", travelDist];
    
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;
    span.longitudeDelta = 0.002;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);


    [_mapView setRegion:region animated:true];
    
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Did fail with error %@", kCFErrorLocalizedDescriptionKey);
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
