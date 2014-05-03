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

@implementation MainViewController


@synthesize currentCardIndex;
@synthesize currentTag;
@synthesize cardMax;


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
    
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    [swipeRecognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:swipeRecognizerLeft];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    [swipeRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:swipeRecognizerRight];
    
    currentCardIndex = 0;
    currentTag = @"Block01";
    [self setCard];
    
    [[_webView scrollView] setBounces:NO];
    [[_webViewCardBack scrollView] setBounces:NO];
    
}


-(void)setCard {
    NSMutableString *queryCard = [[NSMutableString alloc] initWithString:@"select * from notes where tags like '%"];
    [queryCard appendString:(NSString *)currentTag];
    [queryCard appendString:@"%' order by sfld desc limit 1 offset "];
    [queryCard appendFormat:@"%d", (int)currentCardIndex];
    
    //NSLog(@"%@", queryCard);
    
    NSMutableString *queryCardCount = [[NSMutableString alloc] initWithString:@"select count(*) as cnt from notes where tags like '%"];
    [queryCardCount appendString:(NSString *)currentTag];
    [queryCardCount appendString:@"%' order by sfld desc"];
    
    FMDatabase *database = [self openDatabase];
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
        
        NSData *mediaJsonData = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"media" ofType: nil]];
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:mediaJsonData options:0 error:nil];
        
        
        __block NSURL *url;
        [parsedObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([frontAndBack[0] rangeOfString:obj].location != NSNotFound) {
                NSData *data = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: key ofType: nil]];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDirectory = [paths objectAtIndex:0];
                NSString* file= [documentDirectory stringByAppendingPathComponent:obj];
                
                UIImage *image = [UIImage imageWithData:data];
                
                //CGRect screenBounds = [[UIScreen mainScreen] bounds];
                CGSize screenSize = CGSizeMake(150, 150);
                
                image = [self scaleImage:image toSize:screenSize];
                
                data = UIImagePNGRepresentation(image);
                
                
                [data writeToFile:file atomically:YES];
                url = [NSURL fileURLWithPath:documentDirectory];
                
                *stop = YES;
            }
        }];
        
        

        
        NSString *front = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", frontAndBack[0]];
        NSString *back = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", frontAndBack[1]];
        
        [_webView loadHTMLString:front baseURL:url];
        [_webViewCardBack loadHTMLString:back baseURL:url];
        
        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].style.width = '280px'"];
        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].style.height = '280px'"];

    }
    @catch (NSException *exception)
    {
        [NSException raise:@"could not execute query" format:nil];
    }
    @finally {
        [resultCard close];
        [resultCount close];
        [database close];
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

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
