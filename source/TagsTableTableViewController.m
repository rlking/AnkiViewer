//
//  TagsTableTableViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 25.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "TagsTableTableViewController.h"
#import "Deck.h"

@interface TagsTableTableViewController ()

@end

NSArray *tags;

@implementation TagsTableTableViewController

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
    tags = [[Deck getInstance] getTags];
    [self.tableView reloadData];
    
    // get index of current tag
    NSInteger tagIndex = 0;
    tagIndex = [tags indexOfObject:[Deck getInstance].currentTag];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tagIndex inSection:0];
    if (indexPath.row < [self.tableView numberOfRowsInSection:indexPath.section]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"TagTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = tags[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[Deck getInstance] setTag:tags[indexPath.row]];
}



@end
