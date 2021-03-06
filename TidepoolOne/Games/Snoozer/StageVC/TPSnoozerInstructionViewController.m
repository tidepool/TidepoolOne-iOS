//
//  TPSnoozerInstructionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerInstructionViewController.h"
#import "TPSnoozerStageViewController.h"

@interface TPSnoozerInstructionViewController ()

@end

@implementation TPSnoozerInstructionViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.startButton addTarget:(TPSnoozerStageViewController *)self.stageVC action:@selector(instructionDone) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Snoozer Instruction Screen %@", self.levelNumberLabel.text]];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Snoozer Instruction Screen" properties:@{@"stage":self.levelNumberLabel.text}];
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
