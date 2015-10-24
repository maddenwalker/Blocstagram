//
//  ImageLibraryViewController.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/24/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageLibraryViewController;

@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface ImageLibraryViewController : UICollectionViewController

@property (weak, nonatomic) NSObject <ImageLibraryViewControllerDelegate> *delegate;

@end
