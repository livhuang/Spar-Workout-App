//
//  WorkoutViewController.m
//  Spår
//
//  Created by Olivia Huang on 5/3/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "WorkoutViewController.h"
#import "Workout.h"
#import "DisplayWorkoutViewController.h"
#import "AddWorkoutViewController.h"
#import "WorkoutHistoryViewController.h"
#import <UIKit/UIKit.h>
@import Firebase;


@interface WorkoutViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *workoutPicker;
@property(nonatomic) NSArray *pickerData;
@property (nonatomic) NSMutableArray *workoutHistory;
@property (strong, nonatomic) NSArray *cardio;
@property (strong, nonatomic) NSArray *strength;
@property (strong, nonatomic) NSMutableArray *cardioAndStrength;

@property (nonatomic) Workout *currentWorkout;
@property (nonatomic) NSMutableArray *currentExercises;
@property (nonatomic) NSMutableArray *currentDurations;
@property (weak, nonatomic) IBOutlet UITableView *workoutTable;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@property (weak, nonatomic) IBOutlet UIButton *recent;
@property (weak, nonatomic) IBOutlet UIButton *generate;
@property (weak, nonatomic) IBOutlet UIButton *random;
@property (weak, nonatomic) IBOutlet UIButton *zodiac;
@property (weak, nonatomic) IBOutlet UIButton *pressMe;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recent.layer.cornerRadius = 10;
    [_recent.layer setShadowOffset:CGSizeMake(5, 5)];
    [_recent.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_recent.layer setShadowOpacity:0.5];
    
    _generate.layer.cornerRadius = 10;
    [_generate.layer setShadowOffset:CGSizeMake(5, 5)];
    [_generate.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_generate.layer setShadowOpacity:0.5];
    
    _random.layer.cornerRadius = 10;
    [_random.layer setShadowOffset:CGSizeMake(5, 5)];
    [_random.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_random.layer setShadowOpacity:0.5];
    
    _zodiac.layer.cornerRadius = 10;
    [_zodiac.layer setShadowOffset:CGSizeMake(5, 5)];
    [_zodiac.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_zodiac.layer setShadowOpacity:0.5];
    
    _pressMe.layer.cornerRadius = 10;
    [_pressMe.layer setShadowOffset:CGSizeMake(5, 5)];
    [_pressMe.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_pressMe.layer setShadowOpacity:0.5];
    
    
    //workouts array of type Workout object
    _workoutHistory = [[NSMutableArray alloc]init];
    _currentExercises = [[NSMutableArray alloc]init];
    _currentDurations = [[NSMutableArray alloc] init];
    
    UIPickerView * workoutPicker = [UIPickerView new];
    self.workoutPicker.delegate = self;
    self. workoutPicker.dataSource = self;
    [self.view addSubview:workoutPicker];
    
    //initialize data
    self.pickerData = @[@"Cardio", @"Strength", @"Cardio & Strength"];
    
    //select Cardio as default workout
    [workoutPicker selectRow:0 inComponent:0 animated:YES];
    
    
    
    //INITIALIZE EXERCISES
    
    //There are 20 cardio exercises here:
    _cardio = @[@"Jumping Jacks", @"High Knees", @"Burpees", @"Jump Squats", @"Sprint", @"Mountain Climber",
                        @"Plank Jacks", @"Butt Kicks", @"Fast feet shuffle",@"Split Jump", @"Tuck Jump", @"Invisible Jump Rope",
                        @"Skater Hops", @"Flutter Kick", @"Lateral Jump",@"Jumping Lunges", @"Bicycle Crunches", @"Toe Taps",
                        @"Trunk Rotations", @"Plank"];
    
    
    //there are 20 strength exercises here
    _strength = @[@"Squats", @"Side Plank Dips", @"Crunches", @"Sit Ups", @"Plank with T-Rotations", @"Push Ups",
                        @"Side Plank Twists", @"Fire Hydrants", @"Hip Thrusters", @"Plank-Ups", @"Forward Leg Lunges", @"Reverse Leg Lunges",@"Lateral Leg raises", @"Donkey Kicks", @"Scissors", @"Hip Abduction", @"Seated Row", @"V-Ups",@"Straight Leg Raises", @"Russian Twists"];
    
    _cardioAndStrength = [[NSMutableArray alloc]init];
    [_cardioAndStrength addObjectsFromArray:_cardio];
    [_cardioAndStrength addObjectsFromArray:_strength];
    
    //set up database and read workouts for table
    [self configureDatabase];
    [self configureTable];
    [_workoutTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"Cell"];
    self.workoutTable.delegate = self;
    self.workoutTable.dataSource = self;
    NSLog(@"workout history size %lu", _workoutHistory.count);
    
    
    
    
    }


    //set up the database reference
- (void)configureDatabase {
        _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
    NSLog(@"%@", _ref.key);
}

- (void)configureTable {
    [_ref
              observeEventType:FIRDataEventTypeChildAdded
              withBlock:^(FIRDataSnapshot *snapshot) {
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                while (child = [children nextObject]) {
                    NSLog(@"%@", child.key);
                    [self->_workoutHistory addObject:[NSString stringWithFormat:@"%@",child.key]];
                    [self.workoutTable insertRowsAtIndexPaths:@[
                      [NSIndexPath indexPathForRow:self.workoutHistory.count - 1 inSection:0]
                    ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
           //NSLog(@"%@", self->_workoutHistory);
        
        
    }];
    [_workoutTable reloadData];
    
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
        static NSString *Cell = @"Cell";     // Dequeue cell
         UITableViewCell *cell = [_workoutTable dequeueReusableCellWithIdentifier:Cell forIndexPath:indexPath];

        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:Cell];
             }
     
        cell.textLabel.text = [_workoutHistory objectAtIndex:indexPath.row];
        
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
        
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return _workoutHistory.count;
}


- (void) printWorkoutArrayInfo{
    NSLog(@"BEGIN PRINT WOKROUT INFO ARRAY total # of workouts is: %lu", _workoutHistory.count);
    
    
    for(Workout *workout in _workoutHistory){
        
        NSLog(@"NEW WORKOUT..........");
        for(int i = 0; i < _workoutHistory.count; i ++){
            NSLog(@"first object????? ::  %@",[workout.exercises objectAtIndex:i]);
        }
        
        
        
        NSLog(@"workout.exercises: %@",workout.exercises  );
        NSLog(@"workout.durations: %@",workout.duration  );
        NSLog(@"END OF THE WORKOUT");
    }

    NSLog(@"count of workout array %lu",(unsigned long)[_workoutHistory count]);
    

}




- (IBAction)generateWorkoutButtonPressed:(UIButton *)sender {
    
    //empty the current exercises and durations at the beginning of each generate function so you can refill them
    [_currentExercises removeAllObjects];
    [_currentDurations removeAllObjects];

    
    //var for selected row
    NSInteger selectedRow = [_workoutPicker selectedRowInComponent:0];
    //Create new Workout object
    Workout *workout = [[Workout alloc] init];
    
    workout.workoutType = @"Your Randomized Workout";
    
    /*USERS CAN SELECT BETWEEN:

    1) CARDIO         -- Timed. This can be in measures of seconds (i.e. first three are 45 sec, last two 60 sec, etc)
    2) STRENGTH       -- Reps. (first exercises are 20 reps, last two are 25 reps)
    3) RANDOM (mix of cardio & strength)
     
    EACH WORKOUT CIRCUIT IS 4 INTERVALS EACH
    (if there is time, you can select easy, intermediate, hard mode if there's time where easy is 4, interm is 6, hard is 8...)
    */

    NSString *exercise;
    switch (selectedRow) {
            
        //CARDIO
        case 0:
            for (int i = 0; i <5; i ++){
                exercise = _cardio[arc4random_uniform(20)];
                NSLog(@"workout #%d is: %@", i, exercise);

                [_currentExercises addObject:exercise];
                
                //add time to workout object's duration array
                if(i<=2) [_currentDurations addObject:@"duration: 60 seconds"];
                else [_currentDurations addObject:@"duration: 90 seconds"];
            }
            break;
        
        //STRENGTH
        case 1:
            for (int i = 0; i <5; i ++){
                exercise = _strength[arc4random_uniform(20)];
                NSLog(@"workout #%d is: %@", i, exercise);
  
                [_currentExercises addObject:exercise];
                
                if(i<=2) [_currentDurations addObject:@" 20 reps"];
                else [_currentDurations addObject:@"25 reps"];
            }

            break;
            
        //CADRIO & STRENGTH
        case 2:
            //the randomlyGenerateWorkout function generates between both the cardio & strength exercises
            [self randomlyGenerateWorkout];
            break;
    }
    
    [self updateWorkoutData: workout];
    
   // [self printWorkoutArrayInfo];
}


-(void)updateWorkoutData: (Workout*) workout{
    
    workout.exercises = _currentExercises;
    workout.duration = _currentDurations;
    
    [_workoutHistory addObject:workout];
    _currentWorkout = workout;
    NSLog(@"currentWorkout.exercises: %@", _currentWorkout.exercises);
    NSLog(@"currentWorkout.durations: %@", _currentWorkout.duration);
}

//this is if either the Random, Zodiac, or Press me! buttons are pressed
- (IBAction)otherGenerateWorkoutButtonPressed:(UIButton *)sender {
    //all these other workouts are random
    [self randomlyGenerateWorkout];
}


-(void)randomlyGenerateWorkout{
   
    [_currentExercises removeAllObjects];
    [_currentDurations removeAllObjects];
    
    Workout *workout = [[Workout alloc] init];
    NSString *exercise;
    
    //generates workout randomly
    for (int i = 0; i <5; i ++){
          
        //generates random number: 0 or 1
        NSUInteger r = arc4random_uniform(2);
          
        //if r==0, retrieve exercise from _cardio array
        if (r==0){
            exercise = _cardio[arc4random_uniform(20)];
            NSLog(@"workout #%d is: %@", i, exercise);

            [_currentExercises addObject:exercise];

            //add time to workout object's duration array
            if(i<=2) [_currentDurations addObject:@"duration: 60 seconds"];
            else [_currentDurations addObject:@"duration: 90 seconds"];

        //else r==1, retrieve exercise from _strength array
        }else{
            exercise = _strength[arc4random_uniform(20)];
            NSLog(@"workout #%d is: %@", i, exercise);

            [_currentExercises addObject:exercise];

            if(i<=2) [_currentDurations addObject:@" 20 reps"];
            else [_currentDurations addObject:@"25 reps"];
        }

    }//end for loop
    
    [self updateWorkoutData: workout];
    _currentWorkout = _workoutHistory.lastObject;
}






//---------------------- picker delegates

// The number of columns
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// The number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerData.count;
}


 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     NSString * workoutType;
     switch(row) {
             case 0:
             workoutType = @"Cardio";    //Cardio
                 break;
             case 1:
                 workoutType = @"Strength";   //Strength
                 break;
             case 2:
                 workoutType = @"Cardio & Strength";  //Cardio & Strength
                 break;
     }
     return workoutType;
 }


- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"PICKER DID SELECT ROW");
    NSString *selectedRow = [self.pickerData objectAtIndex:[self.workoutPicker selectedRowInComponent:0]];
    NSLog(@"SELECTED PICKER ROW: %@", selectedRow);
    
    NSLog(@"Selected Workout: %@. Index of selected workout: %li", [self.pickerData objectAtIndex:row], (long)row);
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Pass the workout array into DisplayWorkoutViewController.
    if ([segue.identifier  isEqualToString: @"addWorkoutSegue"]){
        //make the AddWorkoutViewController the destinationViewController
        AddWorkoutViewController *addWorkoutView = segue.destinationViewController;
    
        //pass any information here
        
    }else if ([segue.identifier isEqualToString:@"workoutHistorySegue"]){
        //make the WorkoutHistoryViewController the destinationViewController
        WorkoutHistoryViewController *workoutHistoryView = segue.destinationViewController;
        workoutHistoryView.workouts = _workoutHistory;
        
        
        
    //else, one of the generateWorkout buttons has been pressed, so make DisplayWorkoutViewController the destinationViewController
    }else{
        //else, workoutInfoView is the destinationViewController
        DisplayWorkoutViewController *displayWorkoutView = segue.destinationViewController;
        
        displayWorkoutView.currentWorkout = _currentWorkout;


        for (NSString *currentExercises in _currentExercises){
            displayWorkoutView.exercises = _currentExercises;
            displayWorkoutView.duration = _currentDurations;
    //        displayWorkoutView.currentWorkout = _workouts.lastObject;

         }
    }

    
}

- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
