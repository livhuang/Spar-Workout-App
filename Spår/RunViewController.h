//
//  RunViewController.h
//  Spår
//
//  Created by Nassir Ali on 5/5/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunViewController : UIViewController <CLLocationManagerDelegate , MKMapViewDelegate> {
    CLLocationManager *locationManager;
}


@end

NS_ASSUME_NONNULL_END
