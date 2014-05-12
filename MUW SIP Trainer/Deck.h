//
//  Deck.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 04.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "FMDatabase.h"

@interface Deck : NSObject

+ (Card *) getCardForIndex:(NSInteger) index inCategory:(NSString *) category;
+ (Card *) getCardSimpleForIndex:(NSInteger) index inCategory:(NSString *) category;
+ (NSArray *) getCardsSimpleInCategory:(NSString *) category;
+ (NSInteger) getMaxCardForCategory: (NSString *) category;
+ (NSDictionary *) getMediaMapping;
+ (FMDatabase*)openDatabase;

@end


static NSDictionary *mediaMapping;