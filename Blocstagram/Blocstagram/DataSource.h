//
//  DataSource.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

+(instancetype) sharedInstance;
+(NSString *) instagramClientID;

@property (strong, nonatomic, readonly) NSArray *mediaItems;
@property (strong, nonatomic, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;
- (void) downloadImageForMediaItem:(Media *)mediaItem;
- (void) moveMediaItemToFirstInArray:(Media *)item;
- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

@end
