//
//  SettingsViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 30.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bool hideAnswer = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:keyHideAnswer]) {
        hideAnswer = [[NSUserDefaults standardUserDefaults]
                      boolForKey:keyHideAnswer];
    }
    [_switchAnswer setOn:hideAnswer];
    
    [_switchAnswer addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)setState:(id)sender {
    if(sender == _switchAnswer) {
        [[NSUserDefaults standardUserDefaults]
         setBool:_switchAnswer.isOn forKey:keyHideAnswer];
    }
}


@end
