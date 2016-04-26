#import "AsyncOperation.h"

typedef NS_ENUM(NSInteger, AsyncOperationStateEnum) {
    AsyncOperation_Unknown,
    AsyncOperation_Executing,
    AsyncOperation_Finished
};

@interface AsyncOperation()

@property (nonatomic) AsyncOperationStateEnum internalState;

@end

@implementation AsyncOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _internalState = AsyncOperation_Unknown;
    }
    return self;
}

- (BOOL)isConcurrent {
    return [self isAsynchronous];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    @synchronized (self) {
        return self.internalState == AsyncOperation_Executing;
    }
}

- (BOOL)isFinished {
    @synchronized (self) {
        return self.internalState == AsyncOperation_Finished;
    }
}

- (void)transitionToStartedState {
    if (self.internalState != AsyncOperation_Executing) {
        [self willChangeValueForKey:@"isExecuting"];
        @synchronized (self) {
            self.internalState = AsyncOperation_Executing;
        }
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)transitionToFinishedState {
    if (self.internalState != AsyncOperation_Finished) {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        @synchronized (self) {
            self.internalState = AsyncOperation_Finished;
        }
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
}

@end