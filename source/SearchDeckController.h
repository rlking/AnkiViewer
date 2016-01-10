//
//  SearchDeckController.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 19.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchDeckController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldWeb;
@property (weak, nonatomic) IBOutlet UIButton *buttonGo;

@end
