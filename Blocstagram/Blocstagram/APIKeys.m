//
//  APIKeys.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/8/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "APIKeys.h"

@implementation APIKeys

- (NSString *)valueForAPIKey:(NSString *)keyName {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [dictionary valueForKey:keyName];
}

@end
