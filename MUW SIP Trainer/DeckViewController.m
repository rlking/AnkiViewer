//
//  DeckViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 20.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "DeckViewController.h"
#import "Deck.h"
#import "MBProgressHud.h"

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

-(void) viewWillAppear:(BOOL)animated {
    decks = [Deck getDecks];
    [self.tableViewDecks reloadData];
    
    // get index of current deck
    NSInteger deckIndex = 0;
    deckIndex = [decks indexOfObject:[Deck getInstance].currentDeck];
    if (deckIndex == NSNotFound) {
        deckIndex = -1;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:deckIndex inSection:0];
    if (indexPath.row < [self.tableViewDecks numberOfRowsInSection:indexPath.section]) {
        [self.tableViewDecks selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
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
    static NSString *CellIdentifier = @"DeckTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[NSURL fileURLWithPath:[decks objectAtIndex:indexPath.row]] lastPathComponent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *modalView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //modalView.backgroundColor = [UIColor whiteColor];
    //modalView.alpha = 0.5f;
    
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [mainWindow addSubview:modalView];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:modalView animated:YES];
    hud.labelText = @"Öffne Deck ...";
    hud.userInteractionEnabled = NO;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[Deck getInstance] setDeck:[decks objectAtIndex:indexPath.row]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:modalView animated:YES];
            [modalView removeFromSuperview];
        });
    });
}

@end
