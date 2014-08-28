//
//  SearchCardController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 26.08.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "SearchCardController.h"
#import "Deck.h"
#import "CardSearchCell.h"
#import "Card.h"

@interface SearchCardController ()

- (IBAction)searchClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *cards;

@end

@implementation SearchCardController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cards = [NSArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)searchClicked:(id)sender {
    self.cards = [[Deck getInstance] getCardsSimpleForSearch:self.searchBar.text];
    
    [self.tableView reloadData];
    [self.view endEditing:YES];
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"CardSearchTableItem";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.textLabel.text = [self.cards objectAtIndex:indexPath.row];
//    cell.textLabel.font = [UIFont fontWithName:nil size:10.0];
//    cell.textLabel.numberOfLines = 0;
//    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath];
}

- (CardSearchCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    CardSearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureBasicCell:(CardSearchCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Card *card = [self.cards objectAtIndex:indexPath.row];
    cell.titleLabel.text = card.front;
    cell.subtitleLabel.text = [SearchCardController flattenHtml:card.back];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CardSearchCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cards count];
}

+ (NSString *)flattenHtml: (NSString *) html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString: html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString: @"<" intoString: NULL];
        // find end of tag
        [theScanner scanUpToString: @">" intoString: &text];
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat: @"%@>", text]
                                               withString: @" "];
    } // while //
    return html;
}

@end
