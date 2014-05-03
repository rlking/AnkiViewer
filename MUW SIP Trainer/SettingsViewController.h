//
//  SettingsViewController.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 30.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerTag;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
