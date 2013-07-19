//
//  TPReactionTimeGameCircleView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeGameCircleView.h"
#import "CGHelper.h"

#define REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER 4

@interface TPReactionTimeGameCircleView()
{
    CAShapeLayer *circleLayer;
    CAShapeLayer *concentricCircleLayer[REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER];
    BOOL colorChangeTimerActive;
}
@end

@implementation TPReactionTimeGameCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        colorChangeTimerActive = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    circleLayer = [CAShapeLayer layer];
    CGMutablePathRef path = [CGHelper newCirclePathAtPoint:self.center withRadius:self.radius];
    circleLayer.path = path;
    CGPathRelease(path);
    circleLayer.fillColor = [self.color CGColor];

    for (int i=0;i<REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER;i++) {
        concentricCircleLayer[i] = [CAShapeLayer layer];
        concentricCircleLayer[i].path = circleLayer.path;
        concentricCircleLayer[i].fillColor = CGColorCreateCopyWithAlpha([UIColor redColor].CGColor, 1-0.2*i);
        [self.layer addSublayer:concentricCircleLayer[i]];
    }
    [self.layer addSublayer:circleLayer];

}

-(void)circleTouched
{
    [self.delegate circleViewWasTapped];
}

-(void)animateCirclePress
{
    colorChangeTimerActive = NO;
    for (int i=0;i<REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER;i++) {
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        growAnimation.fromValue = (__bridge id)(concentricCircleLayer[i].path);
        growAnimation.toValue = (__bridge id)([CGHelper newCirclePathAtPoint:self.center withRadius:self.radius + self.radius*0.25*i]);
        growAnimation.duration = 0.25;
        growAnimation.autoreverses = YES;
        [concentricCircleLayer[i] addAnimation:growAnimation forKey:@"path"];
    }
    colorChangeTimerActive = YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        if (CGPathContainsPoint(circleLayer.path, nil, touchPoint, NO)) {
            [self circleTouched];
        }
    }    
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    circleLayer.fillColor = [color CGColor];
}

@end