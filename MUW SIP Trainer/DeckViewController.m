//
//  DeckViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 20.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "DeckViewController.h"
#import "Deck.h"

@interface DeckViewController ()

@end

@implementation DeckViewController

NSArray *decks;

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
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
    decks = [Deck getDecks];
    [self.tableViewDecks reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [decks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[NSURL fileURLWithPath:[decks objectAtIndex:indexPath.row]] lastPathComponent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[Deck getInstance] setDeck:[decks objectAtIndex:indexPath.row]];
}

@end
