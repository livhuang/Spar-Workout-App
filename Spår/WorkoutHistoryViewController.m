//
//  WorkoutHistoryViewController.m
//  Spår
//
//  Created by Olivia Huang on 5/4/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "WorkoutHistoryViewController.h"
#import <UIKit/UIKit.h>
@import Firebase;

@interface WorkoutHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;

@end

@implementation WorkoutHistoryViewController

- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"we got here!!!");
    [self configureDatabase];
    [_historyTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"Cell"];
    
    self.historyTable.delegate = self;
    self.historyTable.dataSource = self;
   [self configureTable];
        
}

- (void)configureDatabase {
    _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
    
}


- (void)configureTable {
    /*[_ref
              observeEventType:FIRDataEventTypeChildAdded
              withBlock:^(FIRDataSnapshot *snapshot) {
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                while (child = [children nextObject]) {
                    NSLog(@"%@", child.key);
                    [self->_workouts addObject:child.key];
                    [self.historyTable insertRowsAtIndexPaths:@[
                      [NSIndexPath indexPathForRow:self.workouts.count - 1 inSection:0]
                    ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
           NSLog(@"%@", self->_workouts);
        
        
    }];*/
    [_historyTable reloadData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"selected row %lu", indexPath.row);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@", cell.textLabel.text);
    [[[_ref child:@"workouts"] child:cell.textLabel.text] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSMutableDictionary *userinfo = snapshot.value;
        NSLog(@"%@" , userinfo);
        NSString *display = [NSString stringWithFormat:@"Name: %@ \n Time: %@ \n Comment: %@ \n Exercises: %@ \n Durations: %@",snapshot.value[@"name"], snapshot.value[@"time"], snapshot.value[@"comment"], snapshot.value[@"exercises"],snapshot.value[@"duration"]];
        [self InformativeAlertWithmsg:display];

    }
     withCancelBlock:^(NSError * _Nonnull error) {
     NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)InformativeAlertWithmsg:(NSString *)msg
{
  UIAlertController *alertvc=[UIAlertController alertControllerWithTitle:@"Your Workout Info" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                              style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                NSLog(@ "Dismiss Tapped");
                              }
                             ];
    [alertvc addAction: action];
    [self presentViewController: alertvc animated: true completion: nil];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *Cell = @"Cell";     // Dequeue cell
         UITableViewCell *cell = [_historyTable dequeueReusableCellWithIdentifier:Cell forIndexPath:indexPath];

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
    return _workouts.count;
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
