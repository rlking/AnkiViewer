//
//  MainViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 29.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "MainViewController.h"
#import "FMDatabase.h"
#import "Deck.h"

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
    cardMax = [Deck getMaxCardForCategory:currentTag];
    [self setCard];
    
    [[_webView scrollView] setBounces:NO];
    [[_webViewCardBack scrollView] setBounces:NO];
    
}


-(void)setCard {
    Card *card = [Deck getCardForIndex:currentCardIndex inCategory:currentTag];

        
        NSMutableString *cardOfCards = [[NSMutableString alloc] initWithString:@""];
        [cardOfCards appendFormat:@"%d", (int)currentCardIndex + 1];
        [cardOfCards appendString:@" / "];
        [cardOfCards appendFormat:@"%d", (int)cardMax];
        
        [_label setText:cardOfCards];
    
    
        __block NSURL *url;
        [[Deck getMediaMapping] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([card.front rangeOfString:obj].location != NSNotFound) {
                
                //load image data from resources
                NSData *data = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: key ofType: nil]];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDirectory = [paths objectAtIndex:0];
                UIImage *image = [UIImage imageWithData:data];

                // resize image to somehow fit the screen
                //CGRect screenBounds = [[UIScreen mainScreen] bounds];
                CGSize screenSize = CGSizeMake(150, 150);
                image = [self scaleImage:image toSize:screenSize];
                data = UIImagePNGRepresentation(image);
                
                //translate the path to what´s expected by the html img src
                NSString* pathForWebView= [documentDirectory stringByAppendingPathComponent:obj];
                [data writeToFile:pathForWebView atomically:YES];
                url = [NSURL fileURLWithPath:documentDirectory];
                
                *stop = YES;
            }
        }];
        
        NSString *front = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", card.front];
        NSString *back = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", card.back];
        
        [_webView loadHTMLString:front baseURL:url];
        [_webViewCardBack loadHTMLString:back baseURL:url];
        
        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].style.width = '280px'"];
        [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].style.height = '280px'"];

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
