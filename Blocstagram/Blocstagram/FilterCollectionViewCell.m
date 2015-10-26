//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/25/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@implementation FilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;
        
        CGFloat thumbnailEdgeSize = self.bounds.size.width; //flowLayout.itemSize.width;
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.tag = imageViewTag;
        self.thumbnail.clipsToBounds = YES;
        
        [self addSubview:self.thumbnail];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        self.label.tag = labelTag;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        self.label.textColor = [UIColor whiteColor];
        
        [self addSubview:self.label];
    }
    return self;

}

@end
