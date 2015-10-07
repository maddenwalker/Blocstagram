//
//  Media.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface Media : NSObject

@property (strong, nonatomic) NSString *idNumber;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSURL *mediaURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSArray *comments;

@end
