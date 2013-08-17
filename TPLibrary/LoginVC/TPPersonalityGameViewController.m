//
//  TPPersonalityGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPersonalityGameViewController.h"

@interface TPPersonalityGameViewController ()
{
    UIWebView *_webView;
    TPLabel *_messageLabel;
    TPOAuthClient *_oauthClient;
}
@end

@implementation TPPersonalityGameViewController

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
	// Do any additional setup after loading the view.
    _oauthClient = [TPOAuthClient sharedClient];
    [self.view setBackgroundColor:[UIColor redColor]];
    _messageLabel = [[TPLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    _messageLabel.centered = YES;
    [self.view addSubview:_messageLabel];
    
    TPButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/3, 100)];
    button.center = CGPointMake(self.view.bounds.size.width/2, 300);
    [button setTitle:@"Play again" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startNewPersonalityGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    requestString = [requestString lowercaseString];
    
    if ([requestString hasPrefix:@"iosaction"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@"iosaction://"] objectAtIndex:1];
        BOOL done = logString.boolValue;
        if (done) {
            [self personalityGameFinishedSuccessfully];
        } else {
            [self personalityGameThrewError];
        }
        return NO;
    }
    return YES;
}

-(void)startNewPersonalityGame
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *request = [_oauthClient requestWithMethod:@"get" path:[NSString stringWithFormat:@"#gameForUser/%@", [_oauthClient oauthToken]] parameters:nil];
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://tide-dev.herokuapp.com/#gameForUser/%@", [_oauthClient oauthToken]]]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [self.view addSubview:_webView];
    } completion:^(BOOL finished) {}];
}

-(void)personalityGameFinishedSuccessfully
{
    [_webView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)personalityGameThrewError
{
    _messageLabel.text = @"There was an error. Please try again";
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [_webView removeFromSuperview];
    } completion:^(BOOL finished) {}];
}

@end
