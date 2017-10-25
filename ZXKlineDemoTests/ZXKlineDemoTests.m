//
//  ZXKlineDemoTests.m
//  ZXKlineDemoTests
//
//  Created by 郑旭 on 2017/8/8.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZXAssemblyView.h"
@interface ZXKlineDemoTests : XCTestCase
@property (nonatomic,strong) ZXAssemblyView *assemeblyView;
@end

@implementation ZXKlineDemoTests

- (void)setUp {
    [super setUp];
    self.assemeblyView = [[ZXAssemblyView alloc] init];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
    
    [self.assemeblyView reDrawMAWithMA1Day:10 MA2:20 MA3:30];
}

@end
