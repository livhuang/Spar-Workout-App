//
//  ViewController.m
//  Spår
//
//  Created by Nassir Ali on 4/22/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "ViewController.h"
@import Firebase;


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profileBUtton;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (weak, nonatomic) IBOutlet UIButton *runButton;
@property (weak, nonatomic) NSMutableArray *workouts;
@property (weak, nonatomic) IBOutlet UITableView *workoutsTable1;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _runButton.layer.cornerRadius = 10;
    [_runButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_runButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_runButton.layer setShadowOpacity:0.5];
    
    _workoutButton.layer.cornerRadius = 10;
    [_workoutButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_workoutButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_workoutButton.layer setShadowOpacity:0.5];
    
    _profileBUtton.layer.cornerRadius = 10;
    [_profileBUtton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_profileBUtton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_profileBUtton.layer setShadowOpacity:0.5];
    // Do any additional setup after loading the view.
    
    _workoutsTable1.delegate = self;
    _workoutsTable1.dataSource = self;
    [_workoutsTable1 registerClass:UITableViewCell.self forCellReuseIdentifier:@"Cell"];
    [self configureDatabase];
    //[self configureTable];

}

-(void)configureDatabase{
    _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
}

- (void)configureTable {
    [_ref
              observeEventType:FIRDataEventTypeChildAdded
              withBlock:^(FIRDataSnapshot *snapshot) {
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                while (child = [children nextObject]) {
                    NSLog(@"%@", child.key);
                    [self->_workouts addObject:child.key];
                    [self.workoutsTable1 insertRowsAtIndexPaths:@[
                      [NSIndexPath indexPathForRow:self.workouts.count - 1 inSection:0]
                    ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
           NSLog(@"%@", self->_workouts);
        
        
    }];
   [_workoutsTable1 reloadData];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *Cell = @"Cell";     // Dequeue cell
         UITableViewCell *cell = [_workoutsTable1 dequeueReusableCellWithIdentifier:Cell forIndexPath:indexPath];

        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:Cell];
             }
        cell.textLabel.text = [_workouts objectAtIndex:indexPath.row];
        
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
    }

- (NSInteger)tableView:(UITableView *)tableView
                     numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", _workouts.count);
    return _workouts.count;
}


@end
