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
#import <UICKeyChainStore.h>
#import <AFNetworking.h>

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (strong, nonatomic) NSArray *mediaItems;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isLoadingOlderItems;
@property (assign, nonatomic) BOOL thereAreNoMoreOlderMessages;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) AFHTTPRequestOperationManager *instagramOperationManager;

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
        [self createOperationManager];
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFileName:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        
                        [self requestNewItemsWithCompletionHandler:nil];
                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
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
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        // Got a token; populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
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
    self.thereAreNoMoreOlderMessages = NO;
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id":minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
        
    }
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        if (maxID) {
            parameters = @{@"max_id":maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(nil);
            }
        }];
    }
}

#pragma mark - access IG api

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                        }
                                        
                                        if (completionHandler) {
                                            completionHandler(nil);
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                        if (completionHandler) {
                                            completionHandler(nil);
                                        }
        }];
    }
}

#pragma mark - Liking Media

- (void) toggleLikeOnMedia:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler {
//    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
//    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeButtonState == LikeStateNotLiked) {
        mediaItem.likeButtonState = LikeStateLiking;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            mediaItem.likeButtonState = LikeStateLiked;
            completionHandler();
        });
        
        //removing ineffectual IG API code
//        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            mediaItem.likeButtonState = LikeStateLiked;
//            mediaItem.numberOfLikes = [NSNumber numberWithInteger:[mediaItem.numberOfLikes integerValue] + 1];
//            
//            if (completionHandler) {
//                completionHandler();
//            }
//        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//            mediaItem.likeButtonState = LikeStateLiked;
//            mediaItem.numberOfLikes = [NSNumber numberWithInteger:[mediaItem.numberOfLikes integerValue] + 1];
//            if (completionHandler) {
//                completionHandler();
//            }
//        }];
        
    } else if (mediaItem.likeButtonState == LikeStateLiked) {
        mediaItem.likeButtonState = LikeStateUnlking;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            mediaItem.likeButtonState = LikeStateNotLiked;
            completionHandler();
        });
        
        //removing ineffectual IG API code
//        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            mediaItem.likeButtonState = LikeStateNotLiked;
//            mediaItem.numberOfLikes = [NSNumber numberWithInteger:[mediaItem.numberOfLikes integerValue] - 1];
//            
//            if (completionHandler) {
//                completionHandler();
//            }
//        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//            mediaItem.likeButtonState = LikeStateNotLiked;
//            mediaItem.numberOfLikes = [NSNumber numberWithInteger:[mediaItem.numberOfLikes integerValue] - 1];
//            if (completionHandler) {
//                completionHandler();
//            }
//        }];
    }
    
    [self saveImages];
}

#pragma mark - Commenting

- (void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText {
    if (!commentText || commentText.length == 0) {
        return;
    }
    
    mediaItem.temporaryComment = nil;
    //let's fake some data
    
    Media *newMediaItem = mediaItem;
    NSDictionary *fakeUser = @{
                               @"full_name" : @"Lucas Lima",
                               @"id" : @"2164795549",
                               @"profile_picture" : @"https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-19/s150x150/11850090_1627855997464420_1857060477_a.jpg",
                               @"username" : @"lucaslima7080",
                               };
    
    Comment *newComment = [[Comment alloc] initWithDictionary:@{@"id" : @"1111", @"text" : commentText, @"from" : fakeUser}];
    NSMutableArray *mutableCommentsArray = [newMediaItem.comments mutableCopy];
    [mutableCommentsArray insertObject:newComment atIndex:0];
    newMediaItem.comments = mutableCommentsArray;
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
    
//    Comment out old IG code
//    
//    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
//    NSDictionary *parameters = @{@"access_token" : self.accessToken, @"text" : commentText};
//    
//    [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        mediaItem.temporaryComment = nil;
//        
//        NSString *refreshMediaURLString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
//        [self.instagramOperationManager GET:refreshMediaURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            Media *newMediaItem = [[Media alloc] initWithDictionary:responseObject];
//            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
//            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
//            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
//        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//            [self reloadMediaItem:mediaItem];
//         }];
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSLog(@"Error: %@", error);
//        NSLog(@"Response: %@", operation.responseString);
//        [self reloadMediaItem:mediaItem];
//    }];
}

- (void) reloadMediaItem:(Media *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}

#pragma mark - AFNetworking

- (void) createOperationManager {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    
    self.instagramOperationManager.responseSerializer = serializer;
    
}

#pragma mark - parsing data

- (void) parseDataFromFeedDictionary:(NSDictionary *)dictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = dictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
        }
        
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        
        //this was a pull-to-refresh request
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
    } else if (parameters[@"max_id"]) {
        
        //this was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            //disable infinite scroll , since there are no more images
            self.thereAreNoMoreOlderMessages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
        
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
}

#pragma mark - helper methods

-(void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            mediaItem.downloadState = MediaDownloadStateHasImage;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                            [self saveImages];
                                        } else {
                                            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            //A Networking Problem
                                            
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                                
                                            }
                                        }
        }];
    }
}

- (NSString *) pathForFileName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

- (void) saveImages {
    if (self.mediaItems.count > 0) {
        //write changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0,numberOfItemsToSave)];
            NSString *fullPath = [self pathForFileName:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write to disk, error: %@", dataError);
            }
        });
    }
}

@end
