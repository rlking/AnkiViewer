//
//  CardSearchCell.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 27.08.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "CardSearchCell.h"

@implementation CardSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
