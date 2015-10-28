//
//  MediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/28/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"
#import "MediaTableViewCell.h"

@interface MediaTableViewCellTests : XCTestCase

@property (strong, nonatomic) Media *testMediaItem;

@end

@implementation MediaTableViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

//    //fakeMediaData
    NSDictionary *testUserDictionary = @{@"id": @"8675309",
                                         @"username" : @"d'oh",
                                         @"full_name" : @"Homer Simpson",
                                         @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    NSDictionary *testCommentDictionary = @{@"id" : @"1111", @"text" : @"This is a test comment", @"from" : testUserDictionary};
    
    NSString *imageName = [NSString stringWithFormat:@"%d.jpg", arc4random_uniform(10)-1];
    UIImage *image = [UIImage imageNamed:imageName];
    
    NSDictionary *testMediaDictionary = @{@"id": @"8675309",
                                          @"user" : testUserDictionary,
                                          @"images" : @{@"standard_resolution" : @{@"url" : @"http://example.com/example.jpg" }},
                                          @"caption" : @{@"text" : @"This is a test caption"},
                                          @"comments" : @{@"data" : @[testCommentDictionary]},
                                          @"likes" : @{@"count" : @1},
                                          @"user_has_liked" : @"YES"} ;

    
    self.testMediaItem = [[Media alloc] initWithDictionary:testMediaDictionary];
    self.testMediaItem.image = image;

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testVaryingSizesOfHeightOfImages {
    
    CGFloat returnHeight = [MediaTableViewCell heightForMediaItem:self.testMediaItem  width:375.0 traitCollection:nil];
    
    XCTAssertEqual(539.5, returnHeight);
                    
}


@end
