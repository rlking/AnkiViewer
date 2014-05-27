//
//  SettingsViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 30.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "SettingsViewController.h"
#import "MainViewController.h"
#import "Deck.h"

@interface SettingsViewController ()

@end

NSArray *tags;
NSArray *cards;


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
    
    [_switchAnswer addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)setState:(id)sender {
    if(sender == _switchAnswer) {
        MainViewController *mainVC =
        [self.tabBarController viewControllers][0];
        
        [mainVC handleShowAnswer];
        }
}


@end
