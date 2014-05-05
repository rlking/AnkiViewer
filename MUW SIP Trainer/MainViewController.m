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
#import "SettingsViewController.h"

@interface MainViewController ()

- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)showAnswer:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowAnswer;

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
    // set label cards i.e. 5 / 433
    NSMutableString *cardOfCards = [[NSMutableString alloc] initWithString:@""];
    [cardOfCards appendFormat:@"%d", (int)currentCardIndex + 1];
    [cardOfCards appendString:@" / "];
    [cardOfCards appendFormat:@"%d", (int)cardMax];
    [_label setText:cardOfCards];
    
    Card *card = [Deck getCardForIndex:currentCardIndex inCategory:currentTag];
    __block NSURL *url;
    [[Deck getMediaMapping] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([card.front rangeOfString:obj].location != NSNotFound ||
            [card.back rangeOfString:obj].location != NSNotFound) {
            
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
    
    //set more readable font than the default webview font
    NSString *front = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", card.front];
    NSString *back = [NSString stringWithFormat:@"<font face='Sans-Serif' size='3'>%@", card.back];
    
    [_webView loadHTMLString:front baseURL:url];
    [_webViewCardBack loadHTMLString:back baseURL:url];
    
    [self handleShowAnswer];
    
    // select element in settings list
    SettingsViewController *settingsVC =
    [self.tabBarController viewControllers][1];
    [settingsVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentCardIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

-(void) handleShowAnswer {
    // hide/show answer button
    SettingsViewController *settingsVC =
    [self.tabBarController viewControllers][1];
    
    if([settingsVC.switchAnswer isOn]) {
        [_buttonShowAnswer setHidden:NO];
        [_webViewCardBack setHidden:YES];
    } else {
        [_buttonShowAnswer setHidden:YES];
        [_webViewCardBack setHidden:NO];
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

- (IBAction)previous:(id)sender {
    [self handleSwipeFromRight:nil];
}

- (IBAction)next:(id)sender {
    [self handleSwipeFromLeft:nil];
}

- (IBAction)showAnswer:(id)sender {
    [_webViewCardBack setHidden:NO];
}
@end
