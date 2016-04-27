#import "RepeatingTimerOperation.h"

@interface RepeatingTimerOperation()

@property (nonatomic) NSTimer *timer;

@end

@implementation RepeatingTimerOperation

- (void)start {
    /* 
     if cancelled prior to starting set isFinished=YES and KVO out in start().
     Failure to do so in start() causes intermitent crashes
     */
    if (self.isCancelled) {
        [self transitionToFinishedState];
        return;
    }
    
    [self transitionToStartedState];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

- (void)cancel {
    /*
     invoke super cancel first and then, if self.isExecuting, cleanup the async task.
     Cancelling an operation introduces race conditions galore!
     
     Be cautious about race conditions when canceling and the task isExecuting.  Your task
     could be isExecuting and not in a position to be cancelled because it is still going 
     through some initialization.  Your best bet might be to await its callback and just 
     drop it on the floor.
     
     In this example, we could [self.timer invalidate] which would prevent more timerFired events
     but it then makes start() a lot more difficult because, as these tests will show, the operation
     could be passed the initial self.isCancelled check and not done with start() and be cancelled.
     We'd then have to add guards around every line to check for isCancelled and handle it appropriately.
     That is a lot of work and it is probably safer to just let it fire and drop the callback on the floor.
     
     Another issue is what happens when an operation is finishing right as it is cancelled?  The operation might
     post an event/callback, or do something that the canceller might not expect.  This gets very messy in a hurry.
     If you keep whatever your operation is doing to one thing like maybe "downloading some data", "process the data",
     "store the data", instead of "downloading some data and then processing it and then storing it" all-in-one you'll be fine.
     
     The bottom line is that, to paraphrase the official class documentation, an operation represents a requested
     unit of work.  Once you start the work you lose all control over it; the queue owns it.  You can request 
     that the operation is cancelled but it's more of a "hi mr. operation, would you mind cancelling your work 
     at the next opportunity that presents itself?  I'd like to do something else now" than a command like 
     "stop executing or else I'll execute you!"
     
     */
    [super cancel];
}

- (void)finish {
    [self.timer invalidate];
    self.timer = nil;
    [self transitionToFinishedState];
}

# pragma mark - timer callback

- (void)timerFired:(NSTimer *)timer {
    
    /* if we get callbacks from the timer after we're cancelled drop them on the floor. */
    if (!self.isCancelled) {
        NSLog(@"timerFired***********************************************************************");
    } else {
        [self finish];
    }
}


@end
