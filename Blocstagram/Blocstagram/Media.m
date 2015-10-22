//
//  Media.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResultionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResultionImageURL) {
            self.mediaURL = standardResultionImageURL;
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        //caption may be null
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
        
        if ([mediaDictionary[@"likes"][@"count"] isKindOfClass:[NSNumber class]]) {
            self.numberOfLikes = mediaDictionary[@"likes"][@"count"];
        } else {
            self.numberOfLikes = @0;
        }
        
        BOOL userHasLiked = [mediaDictionary[@"user_has_liked"] boolValue];
        
        if (userHasLiked) {
            self.likeButtonState = LikeStateLiked;
        } else {
            self.likeButtonState = LikeStateNotLiked;
        }
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        if (self.image) {
            self.downloadState = MediaDownloadStateHasImage;
        } else if (self.mediaURL) {
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeButtonState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeButtonState))];
        self.numberOfLikes = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(numberOfLikes))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeButtonState forKey:NSStringFromSelector(@selector(likeButtonState))];
    [aCoder encodeObject:self.numberOfLikes forKey:NSStringFromSelector(@selector(numberOfLikes))];
}

@end
