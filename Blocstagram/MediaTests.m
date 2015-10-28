//
//  MediaTests.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/28/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testThatInitializationWorks {
    
    NSDictionary *testUserDictionary = @{@"id": @"8675309",
                                       @"username" : @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    NSDictionary *testCommentDictionary = @{@"id" : @"1111", @"text" : @"This is a test comment", @"from" : testUserDictionary};

    
    NSDictionary *testMediaDictionary = @{@"id": @"8675309",
                                          @"user" : testUserDictionary,
                                          @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.example.com/example.jpg"}},
                                          @"caption" : @{@"text" : @"This is a test caption"},
                                          @"comments" : @{@"data" : @[testCommentDictionary]},
                                          @"likes" : @{@"count" : @1},
                                          @"user_has_liked" : @"YES"} ;
    
    Media *testMedia = [[Media alloc] initWithDictionary:testMediaDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, testMediaDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.caption, testMediaDictionary[@"caption"][@"text"], @"The caption should be equal");
    
    

}

@end
