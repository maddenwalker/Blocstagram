//
//  User.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface User : NSObject <NSCoding>

@property (strong, nonatomic) NSString *idNumber;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSURL *profilePictureURL;
@property (strong, nonatomic) UIImage *profilePicture;

- (instancetype) initWithDictionary:(NSDictionary *)userDictionary;

@end
