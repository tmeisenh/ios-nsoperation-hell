#import <XCTest/XCTest.h>

#import "SleepingAsyncOperation.h"
#import "RepeatingTimerOperation.h"

@interface AsyncOperationIntegrationTests : XCTestCase

@property (nonatomic) NSOperationQueue *queue;

@end

@implementation AsyncOperationIntegrationTests

- (void)setUp {
    [super setUp];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.queue.suspended = YES;
}

- (NSOperation *)testOperation {
    return [[RepeatingTimerOperation alloc] init];
//    return [[SleepingAsyncOperation alloc] init];
}

- (void)testWhenAddingOperationsToSuspendedQueue_WhenCancelAll_AndUnsuspendQueue_ThenDoesNotCrash {
    
    self.queue.suspended = YES;
    for (int i = 0; i < 100; i++) {
        NSOperation *op = [self testOperation];
        [self.queue addOperation:op];
    }
    
    [self.queue cancelAllOperations];
    self.queue.suspended = NO;
    
    [self.queue waitUntilAllOperationsAreFinished];
    XCTAssertEqual(0, self.queue.operationCount);
}


- (void)testWhenAddingOperationsToLiveQueue_WhenCancelAll_ThenDoesNotCrash {
    
    self.queue.suspended = NO;
    for (int i = 0; i < 100; i++) {
        NSOperation *op = [self testOperation];
        [self.queue addOperation:op];
    }
    
    [self.queue cancelAllOperations];
    
    [self.queue waitUntilAllOperationsAreFinished];
    XCTAssertEqual(0, self.queue.operationCount);
}

- (void)testWhenAddingOperationsToSuspendedQueue_ThatBecomesLiveWhileAddingOperations_WhenCancelAll_ThenDoesNotCrash {
    
    for (int i = 0; i < 100; i++) {
        NSOperation *op = [self testOperation];
        if (i % 7 == 0) {
            self.queue.suspended = NO;
        }
        [self.queue addOperation:op];
    }
    
    [self.queue cancelAllOperations];
    
    [self.queue waitUntilAllOperationsAreFinished];
    XCTAssertEqual(0, self.queue.operationCount);
}

- (void)testAddingOperationsToLiveQueue_AndPeriodicallyCancelingAllOperations_ThenDoesNotCrash {
    self.queue.suspended = NO;
    
    for (int i = 0; i < 50; i++) {
        for (int k = 0; k < 50; k++) {
            NSOperation *op = [self testOperation];
            [self.queue addOperation:op];
        }
        [self.queue cancelAllOperations];
    }
    
    [self.queue waitUntilAllOperationsAreFinished];
    XCTAssertEqual(0, self.queue.operationCount);
}

@end
