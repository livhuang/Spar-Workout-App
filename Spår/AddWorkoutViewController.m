//
//  AddWorkoutViewController.m
//  Spår
//
//  Created by Olivia Huang on 5/4/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//
#import "AddWorkoutViewController.h"
#import <UIKit/UIKit.h>
@import Firebase;


@interface AddWorkoutViewController () <UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate>
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@property (copy, nonatomic) NSArray* workoutArray;

@property (copy, nonatomic) NSMutableArray *selectedExercises;
@property (copy, nonatomic) NSDictionary* inputToDatabase;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITableView *workoutTable;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;



@end

@implementation AddWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _nameField.layer.cornerRadius = 10;
    _nameField.layer.borderWidth = 2;
    _nameField.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _timeField.layer.cornerRadius = 10;
    _timeField.layer.borderWidth = 2;
    _timeField.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _commentField.layer.cornerRadius = 10;
    _commentField.layer.borderWidth = 2;
    _commentField.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _addButton.layer.cornerRadius = 10;
    [_addButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_addButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_addButton.layer setShadowOpacity:0.5];

    
    self.workoutArray = [[NSMutableArray alloc] initWithObjects:@"Jumping Jacks", @"High Knees", @"Burpees", @"Jump Squats", @"Sprint", @"Mountain Climber",
    @"Plank Jacks", @"Butt Kicks", @"Fast feet shuffle",@"Split Jump", @"Tuck Jump", @"Invisible Jump Rope",
    @"Skater Hops", @"Flutter Kick", @"Lateral Jump",@"Jumping Lunges", @"Bicycle Crunches", @"Toe Taps",
    @"Trunk Rotations", @"Plank",@"Squats", @"Side Plank Dips", @"Crunches", @"Sit Ups", @"Plank with T-Rotations", @"Push Ups",
    @"Side Plank Twists", @"Fire Hydrants", @"Hip Thrusters", @"Plank-Ups", @"Forward Leg Lunges", @"Reverse Leg Lunges",@"Lateral Leg raises", @"Donkey Kicks", @"Scissors", @"Hip Abduction", @"Seated Row", @"V-Ups",@"Straight Leg Raises", @"Russian Twists", nil];
    
    
      [self configureDatabase];
    [_workoutTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"Cell"];
    _workoutTable.delegate = self;
    _workoutTable.dataSource = self;
    [_workoutTable setEditing:YES animated:YES];
    
    }

- (NSInteger)tableView:(UITableView *)tableView
                     numberOfRowsInSection:(NSInteger)section
{
    return [self.workoutArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell = @"Cell";     // Dequeue cell
     UITableViewCell *cell = [_workoutTable dequeueReusableCellWithIdentifier:Cell forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                         initWithStyle:UITableViewCellStyleDefault
                         reuseIdentifier:Cell];
         }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _workoutArray[indexPath.row]];
    
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 2;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    NSLog(@"myArray %@",_selectedExercises);
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



- (void)configureDatabase {
    _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
    
}

- (IBAction)addWorkout:(id)sender {
    NSLog(@"add button presses");
    
    NSDictionary *dictionary = @{
           @"name" : _nameField.text,
        @"time" : _timeField.text,
        @"comment" : _commentField.text,
          // @"exercises": _selectedExercises
    };
    
    [self sendWorkout:dictionary];
    
    [self textFieldShouldReturn:_nameField];
    [self textFieldShouldReturn:_timeField];
    [self textFieldShouldReturn:_commentField];}


// UITextViewDelegate protocol methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.text = @"";
  [self.view endEditing:YES];
  return YES;
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
        
    }/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addRecentWokout:(id)sender {
}

- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishedTyping:(id)sender {
    if (sender == _nameField){
        NSString* tempText = @"  ";
        NSString *test = [tempText stringByAppendingString:_nameField.text];
        _nameField.text = test;
    }
    else if (sender == _timeField){
        NSString* tempText = @"  ";
        NSString *test = [tempText stringByAppendingString:_timeField.text];
        _timeField.text = test;
    }
    else if (sender == _commentField){
        NSString* tempText = @"  ";
        NSString *test = [tempText stringByAppendingString:_commentField.text];
        _commentField.text = test;
    }
}

@end
