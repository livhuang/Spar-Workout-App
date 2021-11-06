//
//  DisplayWorkoutViewController.m
//  Spår
//
//  Created by Olivia Huang on 5/3/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "DisplayWorkoutViewController.h"
#import "WorkoutViewController.h"
#import "Workout.h"
@import Firebase;

@interface DisplayWorkoutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;
@property (weak, nonatomic) IBOutlet UIButton *saveWorkout;

@property (copy, nonatomic) NSDictionary* inputToDatabase;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation DisplayWorkoutViewController{
    NSMutableArray *workoutData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _saveWorkout.layer.cornerRadius = 10;
    [_saveWorkout.layer setShadowOffset:CGSizeMake(5, 5)];
    [_saveWorkout.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_saveWorkout.layer setShadowOpacity:0.5];
    
    NSLog(@"DISPLAY WORKOUT VIEW CONTROLLER BEGIN");
    //change workoutTypeLabel to display the selected workout type (Cardio, Strength, C&S, Random, Zodiac, etc)
    _workoutTypeLabel.text = @"Generated Workout";
  
    workoutData = _exercises;
    NSLog(@"EXERCIES: %@ and exercises count: %lu", _exercises, (unsigned long)_exercises.count);
    NSLog(@"DURATIONS: %@ and durations count %lu", _duration, _duration.count);
    NSLog(@"WORKOUT DATA: %@", workoutData);
       
    [self configureDatabase];
        
            
       
    }

    - (void)configureDatabase {
        _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
        
    }

    - (IBAction)addWorkout:(id)sender {
        NSLog(@"add button presses");
        int r = arc4random_uniform(9999999);
        NSString *randomIndex = [NSString stringWithFormat:@"%d", r ];
        NSDictionary *dictionary = @{
               @"name" : randomIndex,
            @"time" : @"",
            @"comment" : @"Generated Workout",
               @"exercises": _exercises,
               @"durations" : _duration
        };
        
        [self sendWorkout:dictionary];
        
        }


    - (void)sendWorkout:(NSDictionary *)data {
      NSMutableDictionary *mdata = [data mutableCopy];
       

      // Push data to Firebase Database
        [[[_ref child:@"workouts"] child:mdata[@"name"]]setValue:mdata];
        NSLog(@"data added");
        [self InformativeAlertWithmsg: mdata[@"name"]];
    }

    -(void)InformativeAlertWithmsg:(NSString *)msg
    {
      UIAlertController *alertvc=[UIAlertController alertControllerWithTitle:@"Successfully added workout!" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                  style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                    NSLog(@ "Dismiss Tapped");
                                  }
                                 ];
        [alertvc addAction: action];
        [self presentViewController: alertvc animated: true completion: nil];
        
    }









//UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [workoutData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TableItem";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
 
    cell.textLabel.text = [workoutData objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_duration objectAtIndex:indexPath.row];
    
 
    return cell;
}


- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
