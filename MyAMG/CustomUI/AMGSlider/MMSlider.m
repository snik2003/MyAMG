//
//  MMSlider.m
//  mymercedes
//
//  Created by Alexander Koulabuhov on 28/03/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "MMSlider.h"

@implementation MMSlider

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setThumbImage:[UIImage imageNamed:@"handle.png"] forState:UIControlStateNormal];
    [self setThumbImage:[UIImage imageNamed:@"handle-hover.png"] forState:UIControlStateHighlighted];
}

@end
