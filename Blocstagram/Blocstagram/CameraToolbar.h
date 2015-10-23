//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/23/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolbar;

@protocol CameraToolBarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end

@interface CameraToolbar : UIView

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@property (weak, nonatomic) NSObject <CameraToolBarDelegate> *delegate;

@end
