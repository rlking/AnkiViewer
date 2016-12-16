//
//  DeckViewController.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 20.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeckViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewDecks;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;


- (void)asyncLoadDeck: (NSString *) absPath;

@end
