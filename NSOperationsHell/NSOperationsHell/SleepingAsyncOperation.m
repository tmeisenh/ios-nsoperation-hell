#import "SleepingAsyncOperation.h"

@interface SleepingAsyncOperation()

@property (nonnull) NSMutableArray *call;

@end

@implementation SleepingAsyncOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _call = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"stack %@ %p", _call, self);
}

- (void)start {
    [_call addObject:@"start"];
    if (self.isCancelled) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Cancelled before starting %p", self);
        [self transitionToFinishedState];
        return;
    }
    
    [self transitionToStartedState];
    [self main];
}

- (void)main {
    [_call addObject:@"main"];
    NSLog(@"---------------------------------------------- Main %p", self);
    [self dowork];
}

- (void)dowork {
    [_call addObject:@"dowork"];
    [NSThread sleepForTimeInterval:1];
    [self transitionToFinishedState];
}

- (void)cancel {
    [super cancel];
    [_call addObject:@"cancel"];
    if (self.isReady && !self.isExecuting && !self.isFinished) {
        NSLog(@"################################### Cancel w/o starting %p", self);
        /* transitionToStartedState fixes: went isFinished=YES without being started by the queue it is in */
//        [self transitionToStartedState];
//        [self transitionToFinishedState];
    } else {
        NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Cancel after starting %p", self);
        // I'm finished, so I don't care.
        // I'm not ready which in this test case isn't possible
        // I'm executing in which case I'll just finish as normal.
    }
}

@end
