//
//  ProfileViewController.m
//  Spår
//
//  Created by Nassir Ali on 5/2/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "ProfileViewController.h"
@import Firebase;

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *runLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *funLabel;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *birthMonth;
@property (weak, nonatomic) IBOutlet UITextField *birthDay;
@property (weak, nonatomic) IBOutlet UITextField *pounds;
@property (weak, nonatomic) IBOutlet UITextField *kilos;
@property (weak, nonatomic) IBOutlet UITextField *inches;
@property (weak, nonatomic) IBOutlet UITextField *centimeters;
@property (weak, nonatomic) IBOutlet UIButton *saveInfo;
@property (weak, nonatomic) IBOutlet UITextField *birthYear;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation ProfileViewController

- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDatabase];
    [_ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSMutableDictionary *userinfo = snapshot.value;
        self->_nameField.text = snapshot.value[@"name"];
        self->_birthDay.text = snapshot.value[@"birthday"];
        self->_birthMonth.text = snapshot.value[@"birthmonth"];
        self->_birthYear.text = snapshot.value[@"birthyear"];
        self->_pounds.text = snapshot.value[@"weightLB"];
        self->_kilos.text = snapshot.value[@"weightKG"];
        self->_inches.text= snapshot.value[@"heightIN"];
        self->_centimeters.text= snapshot.value[@"heightCM"];        NSLog(@"%@" , userinfo);

    }
     withCancelBlock:^(NSError * _Nonnull error) {
     NSLog(@"%@", error.localizedDescription);
    }];


    _runLabel.layer.cornerRadius = 10;
    [_runLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_runLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_runLabel.layer setShadowOpacity:0.5];
    
    _workoutLabel.layer.cornerRadius = 10;
    [_workoutLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_workoutLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_workoutLabel.layer setShadowOpacity:0.5];
    
    _funLabel.layer.cornerRadius = 10;
    [_funLabel.layer setShadowOffset:CGSizeMake(5, 5)];
    [_funLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_funLabel.layer setShadowOpacity:0.5];
    
    
    _nameField.layer.borderWidth = 2;
    _nameField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _nameField.layer.cornerRadius = 10;
    

    
    _birthMonth.layer.borderWidth = 2;
    _birthMonth.layer.borderColor = [[UIColor whiteColor] CGColor];
    _birthMonth.layer.cornerRadius = 10;

    
    _birthDay.layer.borderWidth = 2;
    _birthDay.layer.borderColor = [[UIColor whiteColor] CGColor];
     _birthDay.layer.cornerRadius = 10;

    
    _birthYear.layer.borderWidth = 2;
    _birthYear.layer.borderColor = [[UIColor whiteColor] CGColor];
    _birthYear.layer.cornerRadius = 10;

    
    _pounds.layer.borderWidth = 2;
    _pounds.layer.borderColor = [[UIColor whiteColor] CGColor];
    _pounds.layer.cornerRadius = 10;

    _kilos.layer.borderWidth = 2;
    _kilos.layer.borderColor = [[UIColor whiteColor] CGColor];
    _kilos.layer.cornerRadius = 10;

    _inches.layer.borderWidth = 2;
    _inches.layer.borderColor = [[UIColor whiteColor] CGColor];
    _inches.layer.cornerRadius = 10;

    _centimeters.layer.borderWidth = 2;
    _centimeters.layer.borderColor = [[UIColor whiteColor] CGColor];
    _centimeters.layer.cornerRadius = 10;

    _saveInfo.layer.cornerRadius = 10;
    [_saveInfo.layer setShadowOffset:CGSizeMake(5, 5)];
    [_saveInfo.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_saveInfo.layer setShadowOpacity:0.5];

    _signOutButton.layer.cornerRadius = 10;
    [_signOutButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [_signOutButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_signOutButton.layer setShadowOpacity:0.5];

    
}

- (void)configureDatabase {
    _ref = [[[[FIRDatabase database] reference] child:@"users"] child:[FIRAuth auth].currentUser.uid];
    NSLog(@"%@", _ref.key);
}

-(void)loadInData{
 
}

- (IBAction)saveUserData:(id)sender {
    NSLog(@"add button presses");
    
    
    
    
    NSDictionary *dictionary = @{
           @"name" : _nameField.text,
        @"birthday" : _birthDay.text,
           @"birthmonth": _birthMonth.text,
           @"birthyear": _birthYear.text,
        @"weightLB" : _pounds.text,
           @"weightKG" : _kilos.text,
           @"heightIN" : _inches.text,
           @"heightCM" : _centimeters.text
          
    };
    
    [self sendData:dictionary];
    
}

- (void)sendData:(NSDictionary *)data {
 NSMutableDictionary *mdata = [data mutableCopy];


 // Push data to Firebase Database
   [_ref updateChildValues:mdata];
   NSLog(@"data added");
    [self InformativeAlertWithmsg: @"Your info has been updated."];
   }

-(void)InformativeAlertWithmsg:(NSString *)msg
   {
     UIAlertController *alertvc=[UIAlertController alertControllerWithTitle:@"Successfully saved!" message:msg preferredStyle:UIAlertControllerStyleAlert];
       UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                 style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                   NSLog(@ "Dismiss Tapped");
                                 }
                                ];
       [alertvc addAction: action];
       [self presentViewController: alertvc animated: true completion: nil];
       
}

- (IBAction)signOut:(UIButton *)sender {
    FIRAuth *firebaseAuth = [FIRAuth auth];
    NSError *signOutError;
    BOOL status = [firebaseAuth signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)weightChosen:(id)sender {
    int weight = [_pounds.text integerValue] * 2.2046;
    _pounds.text = [NSString stringWithFormat:@"%d", [_pounds.text integerValue]];
    _kilos.text = [NSString stringWithFormat:@"%d", weight];
}

- (IBAction)heightChosen:(id)sender {
    int height = [_inches.text integerValue] / 0.39370;
    _inches.text = [NSString stringWithFormat:@"%d", [_inches.text integerValue]];
    _centimeters.text = [NSString stringWithFormat:@"%d", height];
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
