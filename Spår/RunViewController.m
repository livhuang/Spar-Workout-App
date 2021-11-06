//
//  RunViewController.m
//  Spår
//
//  Created by Nassir Ali on 5/5/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "RunViewController.h"
#import "MapKit/MapKit.h"
#import "RunHistoryViewController.h"
@import Firebase;

@interface RunViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *runButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *runTable;
@property (nonatomic) NSMutableArray *runHistory;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation RunViewController


- (void)viewDidLoad {
    [super viewDidLoad];
        
    _runButton.layer.cornerRadius = 10;
    [_runButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_runButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_runButton.layer setShadowOpacity:0.5];
    
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
    
    [self centerViewOnUserLocation];
    [_runTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"Cell"];
    _runTable.delegate = self;
    _runTable.dataSource = self;
    [self configureDatabase];
    _runHistory = [[NSMutableArray alloc] init];
    [self configureTable];
    NSLog(@"after table config %lu in history", _runHistory.count);
    
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *Cell = @"Cell";     // Dequeue cell
        UITableViewCell *cell = [_runTable dequeueReusableCellWithIdentifier:Cell forIndexPath:indexPath];

       if (cell == nil) {
           cell = [[UITableViewCell alloc]
                            initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:Cell];
            }
    
    cell.textLabel.text = [_runHistory objectAtIndex:indexPath.row];
       
       cell.textLabel.textColor = [UIColor blackColor];
       return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"run count in numrowsinsextion %lu", self.runHistory.count);
    return [self.runHistory count];
}

 //set up the database reference
- (void)configureDatabase {
        _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
        
}

- (void)configureTable {
    [[_ref child:@"runs"] observeEventType:FIRDataEventTypeValue
                 withBlock:^(FIRDataSnapshot *snapshot) {
                NSEnumerator *children = [snapshot children];
               FIRDataSnapshot *child;
                NSMutableDictionary *dict = snapshot.value;
                NSLog(@"%@", dict);
       while (child = [children nextObject]) {
           NSLog(@"%@", child.key);
           [self->_runHistory addObject:[NSString stringWithFormat:@"%@",child.key]];
           [self.runTable insertRowsAtIndexPaths:@[
             [NSIndexPath indexPathForRow:self.runHistory.count - 1 inSection:0]
           ] withRowAnimation:UITableViewRowAnimationAutomatic];
       }
        NSLog(@"%@", self->_runHistory);
    }];
    [_runTable reloadData];
    
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"%@", segue.identifier);
    if ([segue.identifier  isEqualToString: @"runHistory"]){
        RunHistoryViewController *runHistoryView = segue.destinationViewController;
        NSLog(@"%@", _runHistory);
        runHistoryView.runs = _runHistory;
    }
}


- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self checkLocationAuthorization];
}
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

//guard against there being no location
    if (locations.lastObject == nil) return;
    CLLocation *currentLocation = locations.lastObject;
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








@end
