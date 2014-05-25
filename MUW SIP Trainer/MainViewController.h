//
//  MainViewController.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 29.04.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIWebView *webViewCardBack;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic) NSInteger currentCardIndex;
@property (weak, nonatomic) NSString *currentTag;
@property (nonatomic) NSInteger cardMax;

-(void)setCard;
-(void) resetView;
-(void) handleShowAnswer;

@end
