//
//  Media.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MediaDownloadState) {
    MediaDownloadStateNeedsImage            = 0,
    MediaDownloadStateDownloadInProgress    = 1,
    MediaDownloadStateNonRecoverableError   = 2,
    MediaDownloadStateHasImage              = 3
};

@class User;

@interface Media : NSObject <NSCoding>

@property (strong, nonatomic) NSString *idNumber;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSURL *mediaURL;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) MediaDownloadState downloadState;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSArray *comments;

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;

@end
