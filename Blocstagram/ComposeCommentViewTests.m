//
//  ComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/28/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"

@interface ComposeCommentViewTests : XCTestCase

@property (strong, nonatomic) ComposeCommentView *testComposeComments;

@end

@implementation ComposeCommentViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testComposeComments = [[ComposeCommentView alloc] init];
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testComposeCommentViewReturnsCorrectBoolean {
    //Test if there is text
    [self.testComposeComments setText:@"Test Text"];
    XCTAssert(self.testComposeComments.isWritingComment == YES);
    
    //Test if there is no text
    [self.testComposeComments setText:@""];
    XCTAssert(self.testComposeComments.isWritingComment == NO);
}

@end
