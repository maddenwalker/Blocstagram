//
//  CameraViewController.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/23/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end

@interface CameraViewController : UIViewController

@property (weak, nonatomic) NSObject <CameraViewControllerDelegate> *delegate;

@end
