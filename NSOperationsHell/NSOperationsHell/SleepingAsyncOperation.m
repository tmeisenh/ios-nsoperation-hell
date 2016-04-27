#import "SleepingAsyncOperation.h"

@implementation SleepingAsyncOperation

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)start {
    if (self.isCancelled) {
        [self transitionToFinishedState];
        return;
    }
    
    [self transitionToStartedState];
    [self main];
}

- (void)main {
    [self dowork];
}

- (void)dowork {
    [NSThread sleepForTimeInterval:1];
    [self transitionToFinishedState];
}

- (void)cancel {
    [super cancel];
    if (self.isReady && !self.isExecuting && !self.isFinished) {
        NSLog(@"################################### Cancel w/o starting %p", self);
        /* transitionToStartedState fixes: went isFinished=YES without being started by the queue it is in */
//        [self transitionToStartedState];
//        [self transitionToFinishedState];
    } else {
        NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Cancel after starting %p", self);
        
        // This is where you'd 
        
        // I'm finished, so I don't care.
        // I'm not ready which in this test case isn't possible
        // I'm executing in which case I'll just finish as normal.
    }
}

@end
