//
//  Deck.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 04.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "Deck.h"

@implementation Deck

+ (Card *) getCardForIndex:(NSInteger) index inCategory:(NSString *) category {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select flds from notes where tags like '%"];
    [queryCard appendString:category];
    [queryCard appendString:@"%' order by sfld desc limit 1 offset "];
    [queryCard appendFormat:@"%d", (int)index];
    
    FMDatabase *database = [Deck openDatabase];
    FMResultSet *resultCard;
    Card* card;
    
    @try
    {
        resultCard = [database executeQuery:queryCard];
        [resultCard next];
        
        // magic ascii separator used by anki for front and back of the card
        NSArray *frontAndBack = [[resultCard stringForColumn:@"flds"]componentsSeparatedByString:[NSString stringWithFormat:@"%c", 31]];
        
        card = [Card alloc];
        card.front = frontAndBack[0];
        card.back = frontAndBack[1];
        
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCard close];
        [database close];
    }
    
    return card;
}


+ (Card *) getCardSimpleForIndex:(NSInteger) index inCategory:(NSString *) category {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select sfld from notes where tags like '%"];
    [queryCard appendString:category];
    [queryCard appendString:@"%' order by sfld desc limit 1 offset "];
    [queryCard appendFormat:@"%d", (int)index];
    
    FMDatabase *database = [Deck openDatabase];
    FMResultSet *resultCard;
    Card* card;
    
    @try
    {
        resultCard = [database executeQuery:queryCard];
        [resultCard next];
        
        NSString *sfld = [resultCard stringForColumn:@"sfld"];
        
        card = [Card alloc];
        card.front = sfld;
        
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCard close];
        [database close];
    }
    
    return card;
}

+ (NSInteger) getMaxCardForCategory: (NSString *) category {
    NSMutableString *queryCardCount = [[NSMutableString alloc] initWithString:@"select count(*) as cnt from notes where tags like '%"];
    [queryCardCount appendString:(NSString *)category];
    [queryCardCount appendString:@"%' order by sfld desc"];
    
    FMDatabase *database = [Deck openDatabase];
    FMResultSet *resultCount;

    @try
    {
        resultCount = [database executeQuery:queryCardCount];
        [resultCount next];
        
        return [resultCount intForColumn:@"cnt"];
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCount close];
        [database close];
    }
    
    return 0;

}

+ (NSDictionary *) getMediaMapping {
    if(!mediaMapping) {
        // get json data to map image files to html img src name
        NSData *mediaJsonData = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"media" ofType: nil]];
        mediaMapping = [NSJSONSerialization JSONObjectWithData:mediaJsonData options:0 error:nil];
    }
    
    return mediaMapping;
}


+ (FMDatabase*)openDatabase
{
    FMDatabase *database;
    @try
    {
        database = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"collection" ofType:@".anki2"]];
        if (![database open])
        {
            [NSException raise:@"could not open db" format:nil];
        }
    }
    @catch (NSException *e)
    {
        // #!
        return nil;
    }
    return database;
}

@end
