//
//  CropBox.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/23/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "CropBox.h"

@interface CropBox ()

@property (strong, nonatomic) NSArray *horizontalLines;
@property (strong, nonatomic) NSArray *verticalLines;
@property (strong, nonatomic) UIToolbar *topView;
@property (strong, nonatomic) UIToolbar *bottomView;

@end

@implementation CropBox

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = NO;
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
        UIColor *blackBG = [UIColor colorWithWhite:0 alpha:.15];
        self.topView.barTintColor = blackBG;
        self.bottomView.barTintColor = blackBG;
        self.topView.alpha = 0.5;
        self.bottomView.alpha = 0.5;
        
        NSMutableArray *views = [@[self.topView, self.bottomView] mutableCopy];
        for (UIView *view in views) {
            [self addSubview:view];
        }
        
        NSArray *lines = [self.horizontalLines arrayByAddingObjectsFromArray:self.verticalLines];
        for (UIView *lineView in lines) {
            [self addSubview:lineView];
        }
    }
    
    return self;
}

- (NSArray *) horizontalLines {
    if (!_horizontalLines) {
        _horizontalLines = [self newArrayOfFourWhiteLines];
    }
    
    return _horizontalLines;
}

- (NSArray *) verticalLines {
    if (!_verticalLines) {
        _verticalLines = [self newArrayOfFourWhiteLines];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteLines {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4 ; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat thirdOfWidth = width / 3;
    CGFloat sizeOfScreen = CGRectGetHeight(self.frame);
    
    self.topView.frame = CGRectMake(0, 0, width, ( sizeOfScreen - width ) / 2 );
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = sizeOfScreen - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    for (int i = 0; i < 4; i++) {
        UIView *horizonalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizonalLine.frame = CGRectMake(0, self.topView.frame.size.height + ( i * thirdOfWidth ), width, 0.5);
        
        CGRect verticalFrame = CGRectMake( i * thirdOfWidth , self.topView.frame.size.height, 0.5, width);
        
        if (i == 3) {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
}


@end
