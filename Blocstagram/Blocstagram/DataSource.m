//
//  DataSource.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "APIKeys.h"
#import "LoginViewController.h"

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (strong, nonatomic) NSArray *mediaItems;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isLoadingOlderItems;
@property (strong, nonatomic) NSString *accessToken;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isLoadingOlderItems;
@property (strong, nonatomic) NSData *responseData;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self registerForAccessTokenNotification];
    }
    
    return self;
}

+ (NSString *) instagramClientID {
    APIKeys *apiKey = [[APIKeys alloc] init];
    return [apiKey valueForAPIKey:@"CLIENT_ID"];
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Notification Center Registration

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.accessToken = note.object;
        // Got a token; populate the initial data
        [self populateDataWithParameters:nil];
    }];
}

#pragma mark - manipulating data

- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

- (void) moveMediaItemToFirstInArray:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO insertObject:item atIndex:0];
}

#pragma mark - completion handler methods

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        //TODO: add images
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO) {
        self.isLoadingOlderItems = YES;
        
        //TODO: add images
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

#pragma mark - access IG api

- (void) populateDataWithParameters:(NSDictionary *)parameters {
    if (self.accessToken) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    self.responseData = data;
                    
                    if (self.responseData) {
                        NSError *jsonError;
                        NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
                        
                        if (feedDictionary) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            });
                        }
                    }

                }];
                
                [dataTask resume];
                
            }
        });
        
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *)dictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", dictionary);
}

@end
