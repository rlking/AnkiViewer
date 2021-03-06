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

@property (nonatomic) NSInteger currentCardIndex;
@property (nonatomic) NSString *currentTag;
@property (nonatomic) NSString *currentDeck;
@property (nonatomic) NSInteger cardMax;

+ (Deck *)getInstance;
+ (NSArray *) getDecks;
- (void) setDeck:(NSString *) deck;
+ (void) deleteDeck:(NSString *) deck;
- (NSArray *) getTags;
- (void) setTag:(NSString *) tag;
- (NSArray *) getCardsSimpleForSearch:(NSString *) searchString;
- (Card *) getCardForIndex:(NSInteger) index inCategory:(NSString *) category;
- (NSArray *) getCardsSimpleInCategory:(NSString *) category;
- (NSInteger) getMaxCardForCategory: (NSString *) category;
// - (NSDictionary *) getMediaMapping;
- (void)setNextCard;
- (void)setPreviousCard;
// + (FMDatabase*)openDatabase;
- (void)loadData;

@end


static NSDictionary *mediaMapping;