//
//  TPSnoozerResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultViewController.h"
#import "TPLocalNotificationManager.h"

@interface TPSnoozerResultViewController ()
{
    NSDictionary *_result;
}
@end

@implementation TPSnoozerResultViewController

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
    self.title = @"Results";
    self.history = @[@220, @270, @230, @250];
    self.gameLevelHistoryView.results = self.history;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Snoozer Result Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Snoozer Result Screen"];
#endif

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"results-bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setResult:(NSDictionary *)result
{
    _result = result;
    if (_result) {
        self.currentFastestTime.text = result[@"speed_score"];
        self.blurbLabel.text = result[@"description"];
        self.animalLabel.text = [result[@"speed_archetype"] uppercaseString];
        if ([self.animalLabel.text hasPrefix:@"PROGRESS"]) {
            self.animalLabel.text = @"";
            self.messageLabel.text = @"";
        }
        self.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@",result[@"speed_archetype"]]];
        NSMutableArray *historyMutable = [result[@"calculations"][@"stage_data"] mutableCopy];
        for (int i=0;i<historyMutable.count;i++){
            historyMutable[i] = historyMutable[i][@"score"];
        }
        self.history = historyMutable;
        self.gameLevelHistoryView.results = self.history;
    }
}

-(NSDictionary *)result
{
    return _result;
}
- (void)shareGame
{
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Share" properties:@{@"item": @"Snoozer"}];
#endif
    NSString *message = [NSString stringWithFormat:@"I just played Snoozer and I'm a %@, scoring %@! Can you do better?", self.animalLabel.text, self.currentFastestTime.text];
    NSURL *url = [NSURL URLWithString:APP_LINK];
    
    NSArray *postItems = @[message, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
    } else {
        // Load resources for iOS 7 or later
        [activityVC setExcludedActivityTypes:@[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact]];
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
    
    
@end
