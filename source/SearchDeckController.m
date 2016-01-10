//
//  SearchViewController.m
//  MUW SIP Trainer
//
//  Created by Philipp König on 19.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import "SearchDeckController.h"
#import "Deck.h"

@interface SearchDeckController ()

@property (nonatomic) UIAlertView *alertView;
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
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"link clicked: %@", request);
        
        // start urlconnection to get head information only (for filename, size)
        NSURL *requestedURL = [request URL];
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:requestedURL];
        [req setHTTPMethod:@"Head"];
        self.clickedLink = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        [self.clickedLink start];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else if(navigationType == UIWebViewNavigationTypeOther) {
        NSLog(@"other: %@", request);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    return YES;
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
        self.alertView =[[UIAlertView alloc ] initWithTitle:response.suggestedFilename
                                                    message:@"Warte auf Server"
                                                   delegate:self
                                          cancelButtonTitle:@"Abbrechen"
                                          otherButtonTitles: nil];
        [self.alertView show];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == self.download) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.streamAPKG close];
        self.receivedBytes = 0;
        self.totalBytes = 0;

        // if deck count = 1, it is the first downloaded deck, and will be automatically opened
        if ([Deck getDecks].count == 1) {
            self.alertView.message = @"sneakyly open first deck :O";
        } else {
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //handle error
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.download cancel];
    [self.streamAPKG close];
    if([[NSFileManager defaultManager] removeItemAtPath: self.apkgPath error: nil]) {
        NSLog(@"deleted incomplete file successfully");
    }
    self.receivedBytes = 0;
    self.totalBytes = 0;
}

- (IBAction)goClicked:(id)sender {
    // if an url is entered, we send a head request to check
    // if it is a direct apkg download link
    //  yes: directly download it
    //  no: load the url in the webview
    

    // start urlconnection to get head information only (for filename, size)
    NSURL *requestedURL = [NSURL URLWithString:self.textFieldWeb.text];
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:requestedURL];
    [req setHTTPMethod:@"Head"];
    self.directURL = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [self.directURL start];

    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
@end
