//
//  WebViewControllerTest.m
//  POCAppRTCTests
//
//  Created by Ashish Rathore on 18/03/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WebViewControllerTest.m"

@interface WebViewControllerTest : XCTestCase

@end

@implementation WebViewControllerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [self testHandleEvent];
    }];
}

- (void)testPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSLog(@"call start");
        [self handleEvent:^(NSString *param) {
            NSLog(@"call end");
        }];
    }];
}

- (void)testHandleEvent
{
    int index = 0;
    while (index < 10) {
        NSLog(@"call start index: %d", index);
        [self handleEvent:^(NSString *param) {
            NSLog(@"call end index: %d", index);
        }];
        index = index + 1;
    }
}

- (void)handleEvent:(void (^)(NSString *))completionHandler
{
    dispatch_semaphore_t auth_request_semaphore = dispatch_semaphore_create(0);
    [self handleGetAuthToken:^(NSString * result) {
        dispatch_semaphore_signal(auth_request_semaphore);
        completionHandler(result);
    }];
    if (![NSThread isMainThread]) {
        dispatch_semaphore_wait(auth_request_semaphore, DISPATCH_TIME_FOREVER);
    } else {
        while (dispatch_semaphore_wait(auth_request_semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        }
    }
}

- (void)handleGetAuthToken:(void (^)(NSString *))completionHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1000 * NSEC_PER_MSEC);
    dispatch_after(time, queue, ^{
        completionHandler(@"Done");
    });
}

@end
