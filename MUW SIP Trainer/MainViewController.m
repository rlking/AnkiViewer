//
//  MainViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 29.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "MainViewController.h"
#import "Deck.h"

NSString * const keyHideAnswer = @"keyHideAnswer";

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelWhiteBG;

@end

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
    
    _label.text = @"";
    
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    [swipeRecognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:swipeRecognizerLeft];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    [swipeRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:swipeRecognizerRight];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAnswer:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.labelWhiteBG addGestureRecognizer:tapGestureRecognizer];
    self.labelWhiteBG.userInteractionEnabled = YES;
    
    
    [[Deck getInstance] loadData];
    
    [[_webView scrollView] setBounces:NO];
    [[_webViewCardBack scrollView] setBounces:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    [self setCard];
    [self handleHideAnswer];
}

-(void) handleHideAnswer {
    bool hideAnswer = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:keyHideAnswer]) {
        hideAnswer = [[NSUserDefaults standardUserDefaults]
                      boolForKey:keyHideAnswer];
    }
    
    // hide/show answer button
    if(hideAnswer) {
        [_webViewCardBack setHidden:YES];
    } else {
        [_webViewCardBack setHidden:NO];
    }
}

-(void)setCard {
    Card *card = [[Deck getInstance] getCardForIndex:[Deck getInstance].currentCardIndex inCategory:[Deck getInstance].currentTag];
    if(!card) {
        return;
    }
    
    // set label cards i.e. 5 / 433
    NSMutableString *cardOfCards = [[NSMutableString alloc] initWithString:@""];
    [cardOfCards appendFormat:@"%d", (int)[Deck getInstance].currentCardIndex + 1];
    [cardOfCards appendString:@" / "];
    [cardOfCards appendFormat:@"%d", (int)[Deck getInstance].cardMax];
    [_label setText:cardOfCards];
    
    // get base url for images
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    documentDirectory = [documentDirectory stringByAppendingString:@"/deck"];
    NSURL *url = [NSURL fileURLWithPath:documentDirectory];
    
    //set more readable font than the default webview font
    NSString *front = [NSString stringWithFormat:@"<style type='text/css'>img { max-width: 100%%; width: auto; height: auto; }</style><font face='Sans-Serif' size='3'>%@", card.front];
    NSString *back = [NSString stringWithFormat:@"<style type='text/css'>img { max-width: 100%%; width: auto; height: auto; }</style><font face='Sans-Serif' size='3'>%@", card.back];
    
    [_webView loadHTMLString:front baseURL:url];
    [_webViewCardBack loadHTMLString:back baseURL:url];
    
    [self handleHideAnswer];
}

-(void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    [[Deck getInstance] setNextCard];
    [self setCard];
}

-(void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    [[Deck getInstance] setPreviousCard];
    [self setCard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
