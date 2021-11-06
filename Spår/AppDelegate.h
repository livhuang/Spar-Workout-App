//
//  AppDelegate.h
//  Spår
//
//  Created by Nassir Ali on 4/22/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleSignIn;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

