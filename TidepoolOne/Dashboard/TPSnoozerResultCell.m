//
//  TPSnoozerResultCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/9/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultCell.h"

@interface TPSnoozerResultCell() <UIScrollViewDelegate>
{
    BOOL _pageControlUsed;
}

@end

@implementation TPSnoozerResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)adjustScrollView
{
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*2, 109);
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDate:(NSDate *)date
{
    _date = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.timeLabel.text = [dateFormatter stringFromDate:date];
    self.fastestTimeLabel.text = @"270";
    self.animalLabel.text = @"DOLPHIN";
    self.animalBadgeImage.image = [UIImage imageNamed:@"anim-badge-dolphin.png"];
}

-(void)setFastestTime:(NSNumber *)fastestTime
{
    _fastestTime = fastestTime;
    self.fastestTimeLabel.text = [NSString stringWithFormat:@"%@", _fastestTime];
}


- (IBAction)changePage:(id)sender {
    _pageControlUsed = YES;
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!_pageControlUsed)
        _pageControl.currentPage = lround(_scrollView.contentOffset.x /
                                          (_scrollView.contentSize.width / _pageControl.numberOfPages));
}


@end