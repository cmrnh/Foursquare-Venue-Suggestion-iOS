//
//  ViewController.h
//  FoursquareVenueExample
//
//  Created by Cameron Hendrix on 8/8/13.
//  Copyright (c) 2013 BurningBarnLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBFoursquareRequestManager;

@interface ViewController : UIViewController
<UITableViewDelegate,
UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) BBFoursquareRequestManager *foursquareManager;

@end
