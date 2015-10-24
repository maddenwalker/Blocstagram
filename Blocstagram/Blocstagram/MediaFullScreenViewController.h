//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/12/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaFullScreenViewController;

@protocol MediaFullScreenViewControllerDelegate <NSObject>

- (void) didTapShareButton:(Media *)mediaItem;

@end

@interface MediaFullScreenViewController : UIViewController

@property (strong, nonatomic) Media *media;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

- (instancetype) initWithMedia:(Media *)media;
- (void) centerScrollView;
- (void) recalculateZoomScale;

@property (weak, nonatomic) id <MediaFullScreenViewControllerDelegate> delegate;


@end
