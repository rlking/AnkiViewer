//
//  MainViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 29.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "MainViewController.h"
#import "FMDatabase.h"

@interface MainViewController ()

@end

FMDatabase *database;
NSInteger currentCardIndex = 0;
NSString *currentTag;
NSInteger cardMax;
NSArray *tags;

@implementation MainViewController

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
    
    
    tags = @[@"Block01", @"Block02", @"Block03", @"Block04", @"Block05", @"Block06"];
    
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    [swipeRecognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:swipeRecognizerLeft];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    [swipeRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:swipeRecognizerRight];

    
    database = [self openDatabase];
    [database open];
    
    [self pickerView:nil didSelectRow:0 inComponent:0];
}

-(void)dealloc {
    [database close];
}

-(void)setCard {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select * from notes where tags like '%"];
    [queryCard appendString:(NSString *)currentTag];
    [queryCard appendString:@"%' order by sfld desc limit 1 offset "];
    [queryCard appendFormat:@"%d", (int)currentCardIndex];
    
    NSLog(@"%@", queryCard);
    
    NSMutableString *queryCardCount = [[NSMutableString alloc] initWithString:@"select count(*) as cnt from notes where tags like '%"];
    [queryCardCount appendString:(NSString *)currentTag];
    [queryCardCount appendString:@"%' order by sfld desc"];
    
    FMResultSet *resultCount;
    FMResultSet *resultCard;
    
    @try
    {
        resultCount = [database executeQuery:queryCardCount];
        [resultCount next];
        
        resultCard = [database executeQuery:queryCard];
        [resultCard next];
        
        NSMutableString *cardOfCards = [[NSMutableString alloc] initWithString:@""];
        [cardOfCards appendFormat:@"%d", (int)currentCardIndex + 1];
        [cardOfCards appendString:@" / "];
        [cardOfCards appendString:[resultCount stringForColumn:@"cnt"]];
        
        cardMax = [resultCount intForColumn:@"cnt"];
        
        [_label setText:cardOfCards];
        
        // magic ascii separator used by anki for front and back of the card
        NSArray *frontAndBack = [[resultCard stringForColumn:@"flds"]componentsSeparatedByString:[NSString stringWithFormat:@"%c", 31]];
        
        [_webView loadHTMLString:frontAndBack[0] baseURL:nil];
        [_webViewCardBack loadHTMLString:frontAndBack[1] baseURL:nil];
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCard close];
        [resultCount close];
    }
}

-(void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    currentCardIndex++;
    if(currentCardIndex == cardMax) {
        currentCardIndex = 0;
    }
    
    [self setCard];
}

-(void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    currentCardIndex--;
    if(currentCardIndex == -1) {
        currentCardIndex = cardMax - 1;
    }
    [self setCard];
}

- (FMDatabase*)openDatabase
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Picker View Data

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return tags.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return tags[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    currentTag = tags[row];
    currentCardIndex = 0;
    [self setCard];
}

@end
