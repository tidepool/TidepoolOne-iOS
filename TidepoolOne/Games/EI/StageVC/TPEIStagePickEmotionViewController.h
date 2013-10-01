//
//  TPEIStagePickEmotionViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPStageViewController.h"

@interface TPEIStagePickEmotionViewController : TPStageViewController


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *drawerView;

@property (weak, nonatomic) IBOutlet UIButton *emo_3_0;
@property (weak, nonatomic) IBOutlet UIButton *emo_3_1;
@property (weak, nonatomic) IBOutlet UIButton *emo_3_2;


@property (weak, nonatomic) IBOutlet UIButton *emo_4_0;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_1;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_2;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_3;

- (IBAction)emotionChosen:(id)sender;

@property (weak, nonatomic) IBOutlet TPLabel *scoreLabel;



@property (assign, nonatomic) int imageIndex;
@property (strong, nonatomic) NSArray *imagesData;
@property (assign, nonatomic) float timeToShow;

@property (strong, nonatomic) NSString *primary;
@property (strong, nonatomic) NSString *secondary;
@property (assign, nonatomic) int instantReplayCount;
@property (assign, nonatomic) BOOL isSecondary;

@end
