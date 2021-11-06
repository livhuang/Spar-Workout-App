//
//  DisplayWorkoutViewController.h
//  Spår
//
//  Created by Olivia Huang on 5/3/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisplayWorkoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString *workoutType;
//properties for generated workouts

@property (strong, nonatomic) NSMutableArray *exercises;
@property (strong, nonatomic) NSMutableArray *duration;
@property (nonatomic) NSMutableArray *workouts;

@property (nonatomic) Workout *currentWorkout;

@end

NS_ASSUME_NONNULL_END
