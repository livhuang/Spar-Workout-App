//
//  Workout.h
//  Spår
//
//  Created by Olivia Huang on 5/3/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Workout : NSObject
@property (nonatomic) int index;

@property (nonatomic) NSString *workoutType;
//properties for generated workouts
@property (strong, nonatomic) NSMutableArray *exercises;
@property (strong, nonatomic) NSMutableArray *duration;

//properties for manually added workouts
@property (nonatomic) NSString *workoutName;
@property (nonatomic) NSString *time;
@property (nonatomic) NSString *comments;


@end

NS_ASSUME_NONNULL_END
