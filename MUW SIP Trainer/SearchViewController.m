//
//  SearchViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 19.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) NSURLConnection *clickedLink;
@property (nonatomic) NSURLConnection *download;
@property (nonatomic) NSOutputStream *streamAPKG;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;

@end

@implementation SearchViewController

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
    
    NSString *urlString = @"https://ankiweb.net/shared/decks/sip";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        //NSLog(@"%@", [requestedURL absoluteString]);
        
        // start urlconnection to get head information only (for filename, size)
        NSURL *requestedURL = [request URL];
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:requestedURL];
        [req setHTTPMethod:@"Head"];
        self.clickedLink = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        [self.clickedLink start];
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@ %lld", response.suggestedFilename, response.expectedContentLength);
    NSLog(@"%@", [response.URL absoluteString]);
    
    if(connection == self.clickedLink) {
        if([response.suggestedFilename rangeOfString:@".apkg"].location != NSNotFound) {
            self.totalBytes = response.expectedContentLength;
            
            // create path in Document dir with filename
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0];
            path = [path stringByAppendingString:@"/"];
            path = [path stringByAppendingString: response.suggestedFilename];
            
            // open stream
            self.streamAPKG = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
            [self.streamAPKG open];
            
            // start download
            NSURLRequest *request = [NSURLRequest requestWithURL:response.URL];
            self.download = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            [self.download start];
            
            // display progress with cancel button
            self.alertView =[[UIAlertView alloc ] initWithTitle:@"Download"
                                                             message:@""
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles: nil];
            [self.alertView show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == self.download) {
        self.receivedBytes += data.length;
        if([self.streamAPKG write:[data bytes] maxLength:data.length] == -1) {
            NSLog(@"error writing to stream");
        }
        
        NSString *progress = [NSString stringWithFormat:@"%lu / %lu kB   progress: %.2f ", self.receivedBytes / 1024, self.totalBytes / 1024, (double) self.receivedBytes / self.totalBytes];
        
        self.alertView.message = progress;
        
        NSLog(@"%lu / %lu kB   progress: %.2f ", self.receivedBytes / 1024, self.totalBytes / 1024, (double) self.receivedBytes / self.totalBytes);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == self.download) {
        [self.streamAPKG close];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //handle error
}
@end
