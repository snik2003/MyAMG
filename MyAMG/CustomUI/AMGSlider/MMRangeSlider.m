//
//  MMRangeSlider.m
//  mymercedes
//
//  Created by Alexander Koulabuhov on 29/02/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "MMRangeSlider.h"

#define animationTime 0.25

@interface MMRangeSlider ()

-(float)xForValue:(float)value;
-(float)valueForX:(float)x;
-(void)updateTrackHighlight;

@end

@implementation MMRangeSlider

@synthesize minimumValue, maximumValue, minimumRange, selectedMinimumValue, selectedMaximumValue;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    
    return self;
}

-(void)initialSetup {
    
    _minThumbOn = false;
    _maxThumbOn = false;
    _padding = 8;
    
    _trackBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-background.png"]];
    _trackBackground.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGRect frame = _trackBackground.frame;
    frame.origin.x = _padding;
    frame.size.width = self.frame.size.width - 2*_padding;
    _trackBackground.frame = frame;
    [self addSubview:_trackBackground];
    
    _track = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-highlight.png"]];
    _track.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _track.image = [_track.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_track setTintColor:self.tintColor];
    [self addSubview:_track];
    
    _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
    _minThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
    _minThumb.contentMode = UIViewContentModeCenter;
    [self addSubview:_minThumb];
    
    _maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
    _maxThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
    _maxThumb.contentMode = UIViewContentModeCenter;
    [self addSubview:_maxThumb];
}


-(void)layoutSubviews
{
//    if (fabs(minimumValue - maximumValue) < 1) {
//        return;
//    }
    
    // Set the initial state
    _minThumb.center = CGPointMake([self xForValue:selectedMinimumValue], _minThumb.center.y);
    _maxThumb.center = CGPointMake([self xForValue:selectedMaximumValue], _maxThumb.center.y);

    [self updateTrackHighlight];
}

-(float)xForValue:(float)value{
    return (self.frame.size.width-(_padding*2))*((value - minimumValue) / (maximumValue - minimumValue))+_padding;
}

-(float) valueForX:(float)x{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

-(float) nearestKeyPointForX:(float)x {
    CGFloat nearestPoint = 0;
    CGFloat minimalDistation = CGFLOAT_MAX;
    
    for (CGFloat value = minimumValue; value <= maximumValue; value += minimumRange) {
        CGFloat valuePoint = [self xForValue:value];
        if (fabs(x - valuePoint) < minimalDistation) {
            minimalDistation = fabs(x - valuePoint);
            nearestPoint = valuePoint;
        }
    }
    
    return nearestPoint;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_minThumbOn && !_maxThumbOn){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    if(_minThumbOn){
        CGFloat selectedX = MAX([self xForValue:minimumValue],MIN(touchPoint.x - distanceFromCenter, [self xForValue:selectedMaximumValue - minimumRange]));
        CGFloat nearestPoint = [self nearestKeyPointForX:selectedX];
        
        [UIView animateWithDuration:animationTime animations:^{
            _minThumb.center = CGPointMake(nearestPoint, _minThumb.center.y);
        }];
        
        selectedMinimumValue = [self valueForX:nearestPoint];
        
    }
    if(_maxThumbOn){
        CGFloat selectedX = MIN([self xForValue:maximumValue], MAX(touchPoint.x - distanceFromCenter, [self xForValue:selectedMinimumValue + minimumRange]));
        CGFloat nearestPoint = [self nearestKeyPointForX:selectedX];
        
        [UIView animateWithDuration:animationTime animations:^{
            _maxThumb.center = CGPointMake(nearestPoint, _maxThumb.center.y);
        }];
        
        selectedMaximumValue = [self valueForX:nearestPoint];
    }
    [self updateTrackHighlight];
    
    
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    
    CGFloat distanceBetweenThumbs = _maxThumb.center.x - _minThumb.center.x;
    CGFloat frameWidthDifference = distanceBetweenThumbs - _maxThumb.frame.size.width;

    CGRect minThumbUXFrame = CGRectMake(_minThumb.frame.origin.x - frameWidthDifference / 2, _minThumb.frame.origin.y, distanceBetweenThumbs, _minThumb.frame.size.height);
    CGRect maxThumbUXFrame = CGRectMake(_maxThumb.frame.origin.x - frameWidthDifference / 2, _maxThumb.frame.origin.y, distanceBetweenThumbs, _maxThumb.frame.size.height);
    
    if(CGRectContainsPoint(/*_minThumb.frame*/ minThumbUXFrame, touchPoint)){
        _minThumbOn = true;
        distanceFromCenter = touchPoint.x - _minThumb.center.x;
    }
    else if(CGRectContainsPoint(/*_maxThumb.frame*/ maxThumbUXFrame, touchPoint)){
        _maxThumbOn = true;
        distanceFromCenter = touchPoint.x - _maxThumb.center.x;
        
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    _minThumbOn = false;
    _maxThumbOn = false;
}

-(void)updateTrackHighlight{
    [UIView animateWithDuration:animationTime animations:^{
        _track.frame = CGRectMake(
                                  _minThumb.center.x,
                                  _track.center.y - (_track.frame.size.height/2),
                                  _maxThumb.center.x - _minThumb.center.x,
                                  _track.frame.size.height
                                  );
    }];
}

@end
