//
//  LikeButton.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/21/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked       = 0,
    LikeStateLiking         = 1,
    LikeStateLiked          = 2,
    LikeStateUnlking        = 3
};

@interface LikeButton : UIButton

@property (assign, nonatomic) LikeState likeButtonState;
@property (assign, nonatomic) NSInteger numberOfLikes;

@end
