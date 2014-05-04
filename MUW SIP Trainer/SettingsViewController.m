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
    
    tags = @[@"Block01", @"Block02", @"Block03", @"Block04", @"Block05", @"Block06"];
    
    [self pickerView:nil didSelectRow:0 inComponent:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Picker View Data

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return tags.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return tags[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    MainViewController *mainVC =
    [self.tabBarController viewControllers][0];
    
    mainVC.currentTag = tags[row];
    mainVC.currentCardIndex = 0;
    mainVC.cardMax = [Deck getMaxCardForCategory:tags[row]];
    [mainVC setCard];
    
    [_tableView reloadData];
}


#pragma mark - Table View Data

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    MainViewController *mainVC =
    [self.tabBarController viewControllers][0];
    
    return mainVC.cardMax;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    MainViewController *mainVC =
    [self.tabBarController viewControllers][0];
    
    Card* card = [Deck getCardSimpleForIndex:indexPath.row inCategory:mainVC.currentTag];
    cell.textLabel.text = card.front;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MainViewController *mainVC =
    [self.tabBarController viewControllers][0];

    mainVC.currentCardIndex = indexPath.row;
    [mainVC setCard];
}

@end
