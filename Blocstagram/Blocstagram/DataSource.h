//
//  DataSource.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+(instancetype) sharedInstance;
@property (strong, nonatomic, readonly) NSArray *mediaItems;
- (void) deleteMediaItem:(Media *)item;
- (void) moveMediaItemToFirstInArray:(Media *)item;

@end
