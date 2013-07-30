//
//  TPReactionTimeResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPReactionTimeResultViewController : UIViewController

@property (nonatomic, strong) NSDictionary *result;
@property (weak, nonatomic) IBOutlet UITextField *minimum;
@property (weak, nonatomic) IBOutlet UITextField *maximum;
- (IBAction)playAgainAction:(id)sender;

@end