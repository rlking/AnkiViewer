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
    
    [self resetView];
    
    [_switchAnswer addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void) resetView {
    tags = [Deck getTags];
    cards = [Deck getCardsSimpleInCategory:@""];
    
    MainViewController *mainVC =
    [self.tabBarController viewControllers][0];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainVC.currentCardIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [_tableViewTags reloadData];
    [_tableView reloadData];
}

- (void)setState:(id)sender {
    if(sender == _switchAnswer) {
        MainViewController *mainVC =
        [self.tabBarController viewControllers][0];
        
        [mainVC handleShowAnswer];
        }
}


#pragma mark - Picker View Data

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - Table View Data

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView) {
        return [cards count];
    } else if(tableView == self.tableViewTags) {
        return tags.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if(tableView == self.tableView) {
        NSString* card = [cards objectAtIndex:indexPath.row];
        cell.textLabel.text = card;
    } else if(tableView == self.tableViewTags) {
        cell.textLabel.text = tags[indexPath.row];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView) {
        MainViewController *mainVC =
        [self.tabBarController viewControllers][0];
        
        mainVC.currentCardIndex = indexPath.row;
        [mainVC setCard];
    } else if(tableView == self.tableViewTags) {
        MainViewController *mainVC =
        [self.tabBarController viewControllers][0];
        
        mainVC.currentTag = tags[indexPath.row];
        mainVC.currentCardIndex = 0;
        mainVC.cardMax = [Deck getMaxCardForCategory:tags[indexPath.row]];
        [mainVC setCard];
        
        cards = [Deck getCardsSimpleInCategory:tags[indexPath.row]];
        [_tableView reloadData];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainVC.currentCardIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
