//
//  AppDelegate.m
//  Spår
//
//  Created by Nassir Ali on 4/22/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;
@import GoogleSignIn;

@interface AppDelegate ()
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FIRApp configure];
  [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    return YES;
}

- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
  return [[GIDSignIn sharedInstance] handleURL:url];
}


- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
  if (error == nil) {
    GIDAuthentication *authentication = user.authentication;
    FIRAuthCredential *credential =
    [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                     accessToken:authentication.accessToken];
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable result, NSError * _Nullable error) {
          if (error) {
            NSLog(@"Error %@", error.localizedDescription);
          }
        }];
  } else {
        NSLog(@"Error %@", error.localizedDescription);
  }
}


- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
  // Perform any operations when the user disconnects from app here.
  // ...
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
