//
//  WorkoutHistoryViewController.h
//  Spår
//
//  Created by Olivia Huang on 5/4/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDelegate>

@property (nonatomic) NSMutableArray *workouts;

@end

NS_ASSUME_NONNULL_END
