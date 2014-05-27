//
//  CardsTableViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 25.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "CardsTableViewController.h"
#import "MainViewController.h"
#import "Deck.h"

@interface CardsTableViewController ()

@end

NSArray *cards;

@implementation CardsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
    cards = [[Deck getInstance] getCardsSimpleInCategory:[Deck getInstance].currentTag];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
        NSString* card = [cards objectAtIndex:indexPath.row];
        cell.textLabel.text = card;

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Deck getInstance].currentCardIndex = indexPath.row;
}

@end
