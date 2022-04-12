//
//  MMRangeSlider.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 29/02/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMRangeSlider : UIControl {

    CGFloat distanceFromCenter;

    CGFloat _padding;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}

@property(nonatomic, assign) CGFloat minimumValue;
@property(nonatomic, assign) CGFloat maximumValue;
@property(nonatomic, assign) CGFloat minimumRange;
@property(nonatomic, assign) CGFloat selectedMinimumValue;
@property(nonatomic, assign) CGFloat selectedMaximumValue;

@end
