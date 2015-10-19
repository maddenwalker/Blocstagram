//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/19/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL presenting;
@property (weak, nonatomic) UIImageView *cellImageView;

@end
