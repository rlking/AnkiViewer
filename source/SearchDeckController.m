//
//  SearchViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 19.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//


#import <WebKit/WebKit.h>
#import "SearchDeckController.h"
#import "Deck.h"
#import "DeckViewController.h"


@interface SearchDeckController ()

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIAlertController *alertView;
@property (nonatomic) NSURLConnection *clickedLink;
@property (nonatomic) NSURLConnection *directURL;
@property (nonatomic) NSURLConnection *download;
@property (nonatomic) NSOutputStream *streamAPKG;
@property (nonatomic) NSString *apkgPath;
@property (nonatomic) long long totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
- (IBAction)goClicked:(id)sender;

@end

@implementation SearchDeckController

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
    [self.textFieldWeb setText:urlString];
    
    
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    self.webView.navigationDelegate = self;
    NSURL *nsurl=[NSURL URLWithString:urlString];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
    [self.viewContainer addSubview:self.webView];
    
 
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"%@", [[navigationAction request] URL]);
    
    NSString *string = [[[navigationAction request] URL] absoluteString];
    // anki web is a form button with hidden data as post request
    // we hijack the following get request
    if ([string rangeOfString:@"downloadDeck"].location != NSNotFound && [[[navigationAction request] HTTPMethod] isEqualToString:@"GET"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[[navigationAction request] URL]];
        [req setHTTPMethod:@"Head"];
        self.directURL = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        [self.directURL start];
        NSLog(@"%@", @"sending head request");
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"%@", response);
    
    BOOL isAPKG = [response.suggestedFilename rangeOfString:@".apkg"].location != NSNotFound &&
    [[[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:@"Content-Type"] isEqualToString:@"application/octet-stream"];
    BOOL startDownload = NO;
    
    if(connection == self.directURL) {
        if(!isAPKG) {
            // if entered url is not a direct download link load it in webview
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.textFieldWeb.text]]];
        } else {
            startDownload = YES;
        }
    } else if(connection == self.clickedLink) {
        if(isAPKG) {
            // stop loading, because dropbox i.e. does some really weird redirects? that would trigger
            // multiple downloads
            [self.webView stopLoading];
            startDownload = YES;
        }
    }
    
    // start download progress
    if(startDownload) {
        self.totalBytes = response.expectedContentLength;
        
        // create path in document dir with filename
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.apkgPath = [paths objectAtIndex:0];
        self.apkgPath = [self.apkgPath stringByAppendingString:@"/"];
        self.apkgPath = [self.apkgPath stringByAppendingString: response.suggestedFilename];
        
        // open stream
        self.streamAPKG = [[NSOutputStream alloc] initToFileAtPath:self.apkgPath append:NO];
        [self.streamAPKG open];
        
        // start download
        NSURLRequest *request = [NSURLRequest requestWithURL:response.URL];
        self.download = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        [self.download start];
        
        // display progress with cancel button
        
        _alertView = [UIAlertController alertControllerWithTitle:response.suggestedFilename message:NSLocalizedString(@"waitforserver", nil) preferredStyle:UIAlertControllerStyleAlert];
        [_alertView addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Abbrechen", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self cancelDialog];
        }]];

        [self presentViewController:_alertView animated:YES completion:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == self.download) {
        self.receivedBytes += data.length;
        if([self.streamAPKG write:[data bytes] maxLength:data.length] == -1) {
            NSLog(@"error writing to stream");
        }
        
        NSString *progress = [NSString stringWithFormat:@"%tu / %lld kB   %d%%", self.receivedBytes / 1024, self.totalBytes / 1024, (int)(((double) self.receivedBytes / self.totalBytes) * 100)];
        
        self.alertView.message = progress;
        
//        NSLog(@"%tu / %lld kB   progress: %2.0f ", self.receivedBytes / 1024, self.totalBytes / 1024, (double) (self.receivedBytes / self.totalBytes) * 100);
    }
}

- (void)cancelDialog{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.download cancel];
    [self.streamAPKG close];
    if([[NSFileManager defaultManager] removeItemAtPath: self.apkgPath error: nil]) {
        NSLog(@"deleted incomplete file successfully");
    }
    self.receivedBytes = 0;
    self.totalBytes = 0;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == self.download) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.streamAPKG close];
        self.receivedBytes = 0;
        self.totalBytes = 0;

        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController popViewControllerAnimated:YES];
            
            // if deck count = 1, it is the first downloaded deck, and will be automatically opened
            if ([Deck getDecks].count == 1) {
                DeckViewController *dvc;
                dvc = (DeckViewController *)[self.navigationController topViewController];
                [dvc asyncLoadDeck:self.apkgPath];
            }
        }];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //handle error
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (IBAction)goClicked:(id)sender {
    // if copied url is a dropbox link with https://www.dropbox.com/,,,,/xxx.apkg?dl=0
    // replace dl=0 with dl=1 to start download immediately
    NSString *urlString = self.textFieldWeb.text;
    urlString = [urlString stringByReplacingOccurrencesOfString:@"dl=0" withString:@"dl=1"];
    NSURL *requestedURL = [NSURL URLWithString:urlString];
    
    
    // if an url is entered, we send a head request to check
    // if it is a direct apkg download link
    //  yes: directly download it
    //  no: load the url in the webview
    

    // start urlconnection to get head information only (for filename, size)
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:requestedURL];
    [req setHTTPMethod:@"Head"];
    self.directURL = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [self.directURL start];

    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
@end
