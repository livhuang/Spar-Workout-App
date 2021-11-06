//
//  RunHistoryViewController.h
//  Spår
//
//  Created by user162319 on 5/6/20.
//  Copyright © 2020 Nassir Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *runs;
@end

NS_ASSUME_NONNULL_END
