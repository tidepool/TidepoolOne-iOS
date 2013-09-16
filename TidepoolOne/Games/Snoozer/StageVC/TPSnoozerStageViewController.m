//
//  TPSnoozerStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerStageViewController.h"
#import "TPSnoozerInstructionViewController.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>

@interface TPSnoozerStageViewController ()
{
    NSMutableArray *_clockViews;
    TPSnoozerClockView *_ringingClockView;
    int _correctTouches;
    int _incorrectTouches;
    NSMutableArray *_eventArray;
    NSTimer *_timer;
    NSDate *_timerDate;
    TPSnoozerInstructionViewController *_instructionVC;
    NSDate *_pauseTime;
    NSDateFormatter *_debugFormatter;
    BOOL _stageDone;
    BOOL _instructionDone;
}

@end

@implementation TPSnoozerStageViewController

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
    //TODO: find better way
    self.view.frame = CGRectOffset(self.view.frame, 0, -20.0);
    self.view.backgroundColor = [UIColor clearColor];
    _clockViews = [NSMutableArray array];
    self.numRows = 3;
    self.numColumns = 2;
    self.numChoices = 0;
    self.numChoicesTotal = 1;
    _eventArray = [NSMutableArray array];
    self.type = @"snoozer";
    _debugFormatter = [[NSDateFormatter alloc] init];
    [_debugFormatter setDateStyle:NSDateFormatterLongStyle];
    _stageDone = NO;
    _instructionDone = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:[NSString stringWithFormat:@"Snoozer Stage Screen, %i",self.gameVC.stage]];

    if (_pauseTime) {
        NSTimeInterval difference = [[NSDate date] timeIntervalSinceDate:_pauseTime];
        for (TPSnoozerClockView *clockView in _clockViews) {
            [clockView resume];
        }
        NSLog(@"time appear: %@", [[NSDate date] description]);
        NSLog(@"time diff: %f", difference);
        NSDate *oldDate = _timerDate;
        NSDate *newDate = [oldDate dateByAddingTimeInterval:difference];

        _timer.fireDate = newDate;
        NSLog(@"TIMER NEW DATE: %@", [_timer.fireDate description]);
        _timerDate = newDate;
        _pauseTime = nil;
    } else {
        [self showInstructionScreen];
    }
    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);    
}

-(void)viewDidLayoutSubviews
{
//    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!_instructionDone) {
        NSLog(@"instruction not done on disappear so returning");
        return;
    }
    if (_stageDone) {
        return;
    }
    _pauseTime = [NSDate date];
    NSLog(@"time disappear: %@", [_pauseTime description]);
//    [_timer invalidate];
//    _timer = nil;
    NSLog(@"original fire date: %@", [_timer.fireDate description]);    
    _timer.fireDate = [[NSDate date] dateByAddingTimeInterval:10000];
    NSLog(@"sentinel fire date: %@", [_timer.fireDate description]);
    for (TPSnoozerClockView *clockView in _clockViews) {
        [clockView pause];
    }
}

-(void)showInstructionScreen
{
    if (_instructionVC) {
        return;
    }
    _instructionVC = [[TPSnoozerInstructionViewController alloc] initWithNibName:@"TPSnoozerInstructionViewController" bundle:nil];
    _instructionVC.view.frame = self.view.frame;
    _instructionVC.stageVC = self;
    _instructionVC.levelNumberLabel.text = [NSString stringWithFormat:@"%i", self.gameVC.stage+1];
    _instructionVC.instructionsDetailLabel.attributedText = [self parsedFromMarkdown:self.data[@"instructions"]];
    _instructionVC.clockViewLeft.currentColor = self.data[@"correct_color_sequence"][0];
    _instructionVC.clockViewRight.currentColor = [self.data[@"correct_color_sequence"] lastObject];
    [_instructionVC.clockViewLeft updatePicture];
    [_instructionVC.clockViewRight updatePicture];
    if (self.gameVC.stage > 0) {
        [self.view addSubview:_instructionVC.view];
        _instructionVC.view.alpha = 0.0;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _instructionVC.view.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.view addSubview:_instructionVC.view];        
    }

}

-(void)instructionDone
{
    _instructionDone = YES;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _instructionVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self layoutClocks];
        [self logTestStarted];
        [_instructionVC.view removeFromSuperview];
        _instructionVC = nil;
    }];
}

-(void)layoutClocks
{
    int boxHeight = self.view.bounds.size.height / self.numRows;
    int boxWidth = self.view.bounds.size.width / self.numColumns;
    _timeToShow = [self.data[@"time_to_show"] floatValue];
    NSArray *shuffledTimeline = [self generateTimelineForCorrectSequence:self.data[@"correct_color_sequence"] incorrectSequences:self.data[@"incorrect_color_sequences"] fractionIncorrect:[self.data[@"fraction_incorrect"] floatValue] timeToShow:_timeToShow minimumTimeGapFraction:[self.data[@"minimum_time_gap_fraction"] floatValue] maximumTimeGapFraction:[self.data[@"maximum_time_gap_fraction"] floatValue] numberCorrectToShow:[self.data[@"number_correct_to_show"] floatValue]];

    NSLog(@"generated %@", [shuffledTimeline description]);
    for (int i=0; i<self.numColumns; i++) {
        for (int j=0; j<self.numRows; j++) {
            TPSnoozerClockView *clockView = [[TPSnoozerClockView alloc] initWithFrame:CGRectMake(i*boxWidth, j*boxHeight, boxWidth, boxHeight)];
            clockView.timeToShow = _timeToShow;
            clockView.isRinging = NO;
            clockView.delegate = self;
            clockView.timeline = shuffledTimeline[self.numRows*i+j];
            clockView.correctColor = self.data[@"correct_color"];
            clockView.correctColorSequence = self.data[@"correct_color_sequence"];
            clockView.tag = self.numRows*i+j+1;
            [self.view addSubview:clockView];
            [_clockViews addObject:clockView];
        }
    }
    [self createTimerForStageEndUsingTimeline:shuffledTimeline];
}


-(NSArray *)generateTimelineForCorrectSequence:(NSArray *)correctSequence incorrectSequences:(NSArray *)incorrectSequences fractionIncorrect:(float)fractionIncorrect timeToShow:(float)timeToShow minimumTimeGapFraction:(float)minimumTimeGapFraction maximumTimeGapFraction:(float)maximumTimeGapFraction numberCorrectToShow:(int)numberCorrectToShow
{
    int numClocks = self.numRows * self.numColumns;
    int numberCorrectShown = 0;
    int lastChosenClock = arc4random()%numClocks;
    int currentClock = arc4random()%numClocks;
    float lastTime = 0;
    NSMutableArray *timeline = [NSMutableArray array];
    for (int i=0;i<numClocks;i++) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        [timeline addObject:mutableArray];
    }
    // Generate timeline for determinate number of correct clocks
    while (numberCorrectShown < numberCorrectToShow) {
        // choose clock other than last chosen
        while (currentClock == lastChosenClock) {
            currentClock = arc4random()%numClocks;
        }
        lastChosenClock = currentClock;
        
        BOOL currentShouldBeCorrect = YES;
        if (fractionIncorrect > 0) {
            currentShouldBeCorrect =  (int)(((float)arc4random() / UINT32_MAX) / fractionIncorrect);
        }
        NSArray *currentSequence;
        if (currentShouldBeCorrect || incorrectSequences.count == 0) {
            currentSequence = correctSequence;
            numberCorrectShown++;
        } else {
            currentSequence = incorrectSequences[arc4random()%incorrectSequences.count];
        }
        float timeDiff = ((float)arc4random() / UINT32_MAX) * timeToShow * (maximumTimeGapFraction - minimumTimeGapFraction);
        if (timeDiff < minimumTimeGapFraction * timeToShow) {
            timeDiff += (minimumTimeGapFraction * timeToShow);
        }
        //show clock - currentClock at time lastShown + timeDiff for timeToShow
        NSMutableArray *timelineForCurrentClock = timeline[currentClock];
        NSDictionary *event = @{@"colors":currentSequence, @"delay":[NSNumber numberWithFloat:lastTime + timeDiff]};
        lastTime += timeDiff;
        [timelineForCurrentClock addObject:event];
    }
    return timeline;
}

-(NSArray *)shuffleArray:(NSArray *)array
{
    NSMutableArray *shuffledArray = [array mutableCopy];
    for (int i=0;i<shuffledArray.count;i++) {
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:(i+(arc4random()%(shuffledArray.count-i)))];
    }
    return shuffledArray;
}


-(void)createTimerForStageEndUsingTimeline:(NSArray *)timeline
{
    NSNumber *maxTime = @0;
    for (NSArray *clockSequence in timeline) {
        for (NSDictionary *item in clockSequence) {
            if ([maxTime floatValue] < [item[@"delay"] floatValue]) {
                maxTime = item[@"delay"];
            }
        }
    }
    float timeToEnd = (1.25*_timeToShow + maxTime.floatValue)/1000;
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeToEnd target:self selector:@selector(stageOver) userInfo:nil repeats:NO];
    NSLog(@"Last clock: %f s", maxTime.floatValue/1000);
    NSLog(@"Timer for stage end after: %f s", timeToEnd);
    _timerDate = _timer.fireDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tappedClockView:(TPSnoozerClockView *)clockView correctly:(BOOL)correct
{
    if (correct) {
        [self logCorrectClockClickedForClock:clockView];
    } else {
        [self logWrongClockClickedForClock:clockView];
    }
}

-(void)showedRingingClockInClockView:(TPSnoozerClockView *)clockView
{
    [self logClockRingForClock:clockView];
}

-(void)showedPossibleClockInClockView:(TPSnoozerClockView *)clockView
{
    [self logClockRingForClock:clockView];
}

-(void)stageOver
{
    //TODO: hack, fix
    if (_pauseTime) {
        return;
    }
    NSLog(@"FIRED AT: %@ scheduled for:", [NSDate date]);
    [self logTestCompleted];
    [self.gameVC currentStageDoneWithEvents:_eventArray];
    _stageDone = YES;
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *eventWithTime = [event mutableCopy];
    [eventWithTime setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"time"];
    [_eventArray addObject:eventWithTime];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_started" forKey:@"event"];
    [event setValue:self.data[@"game_type"] forKey:@"sequence_type"];
    [self logEventToServer:event];
}

-(void)logClockRingForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"shown" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    if ([clockView isTarget]) {
        [event setValue:@"target" forKey:@"type"];
        NSLog(@"ring target");
    } else {
        [event setValue:@"decoy" forKey:@"type"];
        NSLog(@"ring decoy");
    }
    [event setValue:clockView.currentColor forKey:@"color"];
    [self logEventToServer:event];
}

-(void)logCorrectClockClickedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"correct" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    [self logEventToServer:event];
}

-(void)logWrongClockClickedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"incorrect" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_completed" forKey:@"event"];
    [self logEventToServer:event];
    [event setValue:@"level_summary" forKey:@"event"];
    [self logEventToServer:event];
}

-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
    //    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:18.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    NSDictionary *attributes = @{
                                 @(STRONG): @{NSFontAttributeName : strongFont,},
                                 @(EMPH): @{NSForegroundColorAttributeName : emColor,}
                                 };
    // parse the markdown
    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
    
    return prettyText;
    //    // assign it to a view object
    //    myTextView.attributedText = prettyText;
    
}


@end
