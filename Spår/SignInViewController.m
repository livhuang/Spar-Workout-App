//
//  SignInViewController.m
//  Spår
//
//  Created by user162319 on 4/30/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "Constants.h"
#import "MeasurementHelper.h"
#import "SignInViewController.h"

@import Firebase;
@import GoogleSignIn;
@import FirebaseAuth;

@interface SignInViewController ()
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation SignInViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [GIDSignIn sharedInstance].presentingViewController = self;
  [[GIDSignIn sharedInstance] signIn];
  self.handle = [[FIRAuth auth]
                 addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                   if (user) {
                     [MeasurementHelper sendLoginEvent];
                     [self performSegueWithIdentifier:@"SegueToMainView" sender:nil];
                   }
                 }];
}

- (void)dealloc {
  [[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
}

@end
