//
//  Comment.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (strong, nonatomic) NSString *idNumber;
@property (strong, nonatomic) User *from;
@property (strong, nonatomic) NSString *text;

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary;

@end
