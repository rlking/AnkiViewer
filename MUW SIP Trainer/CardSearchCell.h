//
//  CardSearchCell.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 27.08.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const cellIdentifier = @"CardSearchTableItem";

@interface CardSearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

@end
