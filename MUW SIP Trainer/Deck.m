//
//  Deck.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 04.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "Deck.h"
#import "SSZipArchive.h"

static Deck *instance = nil;
// ../Documents/deck/
static NSString *deckPath;

@implementation Deck

@synthesize currentDeck;
@synthesize currentCardIndex;
@synthesize currentTag;
@synthesize  cardMax;

// get singleton
+ (Deck *)getInstance {
    if (instance == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        deckPath = [NSString stringWithFormat:@"%@/deck/",documentPath];
        
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        currentCardIndex = 0;
        currentTag = @"";
        cardMax = 0;
    }
    return self;
}


- (Card *) getCardForIndex:(NSInteger) index inCategory:(NSString *) category {
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
        bool next = [resultCard next];
        if(!next) {
            return nil;
        }
        
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


- (Card *) getCardSimpleForIndex:(NSInteger) index inCategory:(NSString *) category {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select substr(sfld, 0, 35) 'sfld' from notes where tags like '%"];
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

- (NSArray *) getCardsSimpleInCategory:(NSString *) category {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select substr(sfld, 0, 35) 'sfld' from notes where tags like '%"];
    [queryCard appendString:category];
    [queryCard appendString:@"%' order by sfld desc"];
    
    FMDatabase *database = [Deck openDatabase];
    FMResultSet *resultCard;
    NSMutableArray *cards = [NSMutableArray array];
    
    @try
    {
        resultCard = [database executeQuery:queryCard];
        [resultCard next];
        while([resultCard hasAnotherRow]) {
            NSString *sfld = [resultCard stringForColumn:@"sfld"];
            [cards addObject:sfld];
            [resultCard next];
        }
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCard close];
        [database close];
    }
    
    return cards;
}


- (NSInteger) getMaxCardForCategory: (NSString *) category {
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

- (NSDictionary *) getMediaMapping {
    // get json data to map image files to html img src name
    NSData *mediaJsonData = [[NSData alloc] initWithContentsOfFile: [deckPath stringByAppendingString: @"media"]];
    mediaMapping = [NSJSONSerialization JSONObjectWithData:mediaJsonData options:0 error:nil];
    
    return mediaMapping;
}


+ (FMDatabase*)openDatabase
{
    FMDatabase *database;
    @try
    {
        database = [FMDatabase databaseWithPath:[deckPath stringByAppendingString: @"collection.anki2"]];
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

/**
 * @return array of absolute paths to decks
 */
+ (NSArray *) getDecks {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:NULL];
    NSMutableArray *apkgs = [NSMutableArray array];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        if([[directoryContent objectAtIndex:count] rangeOfString:@".apkg"].location != NSNotFound) {
            [apkgs addObject:[NSString stringWithFormat:@"%@/%@",documentPath ,[directoryContent objectAtIndex:count]]];
        }
        //NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    
    return apkgs;
}

/**
 * @param deck absolute path to deck
 */
- (void) setDeck:(NSString *) deck {
    self.currentDeck = deck;
    
    // delete old files
    [[NSFileManager defaultManager] removeItemAtPath:deckPath error:nil];
    
    // unzip deck
    [SSZipArchive unzipFileAtPath:deck toDestination:deckPath];
    
    // rename image files to correct names so the webview can find them
    [[[Deck getInstance] getMediaMapping] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSFileManager defaultManager] moveItemAtPath:[deckPath stringByAppendingString: key] toPath:[deckPath stringByAppendingString: obj] error:nil];
    }];
    
    // reset cards
    currentTag = @"";
    currentCardIndex = 0;
    cardMax = [self getMaxCardForCategory:currentTag];
    
    [self saveData];
}

- (NSArray *) getTags {
    NSMutableSet *ret = [NSMutableSet set];
    NSMutableString *queryTags = [[NSMutableString alloc] initWithString:@"select tags from notes"];
    
    FMDatabase *database = [Deck openDatabase];
    FMResultSet *result;
    
    @try
    {
        result = [database executeQuery:queryTags];
        [result next];
        while([result hasAnotherRow]) {
            NSString *tags = [result stringForColumn:@"tags"];
           
            NSArray *split = [tags componentsSeparatedByString:@" "];
            for (NSString *str in split) {
                [ret addObject:[str stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            
            [result next];
        }
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query tags" format:nil];
    }
    @finally {
        [result close];
        [database close];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    return [[ret allObjects] sortedArrayUsingDescriptors:sortDescriptors];
}

- (void) setTag:(NSString *) tag {
    currentTag = tag;
    currentCardIndex = 0;
    cardMax = [self getMaxCardForCategory:tag];
    
    [self saveData];
}

-(void)setNextCard {
    currentCardIndex++;
    if(currentCardIndex == cardMax) {
        currentCardIndex = 0;
    }
    
    [self saveData];
}

-(void)setPreviousCard {
    currentCardIndex--;
    if(currentCardIndex == -1) {
        currentCardIndex = cardMax - 1;
    }
    
    [self saveData];
}

NSString * const keyCurrentDeck = @"keyCurrentDeck";
NSString * const keyCurrentCardIndex = @"keyCurrentCardIndex";
NSString * const keyCurrentTag = @"keyCurrentTag";
NSString * const keyCurrentCardMax = @"keyCurrentCardMax";

/**
 *
 * Persist current state. I.e. deck, card index etc.
 *
 */
-(void)saveData
{
    [[NSUserDefaults standardUserDefaults]
     setObject:currentDeck forKey:keyCurrentDeck];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:currentTag forKey:keyCurrentTag];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithInt:(int)currentCardIndex] forKey:keyCurrentCardIndex];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithInt:(int)cardMax] forKey:keyCurrentCardMax];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *
 * Load persisted state. I.e. deck, card index etc.
 * Used to restore state after app was closed by ios.
 *
 */
-(void)loadData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:keyCurrentDeck])
    {
        currentDeck = [[NSUserDefaults standardUserDefaults]
                    objectForKey:keyCurrentDeck];
        currentTag = [[NSUserDefaults standardUserDefaults]
                     objectForKey:keyCurrentTag];
        currentCardIndex = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                   objectForKey:keyCurrentCardIndex] intValue];
        cardMax = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                         objectForKey:keyCurrentCardMax] intValue];
    } else {
        currentDeck = @"";
        currentCardIndex = 0;
        currentTag = @"";
        cardMax = 0;
    } 
}

@end
