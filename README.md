# ios-nsoperation-hell

This is an example project that demonstates concurrent/asynchronous NSOperations.  I haven't found a good tutorial that went into detail about the life cycle of an NSOperation when it is Asynchronous.

- AsyncOperation handles the KVO eventing for the two state transitions that I _think_ we care about: executing and finishing.
- SleepingAsyncOperation is an operation that manages its own internal state.  If the operation gets to actually execute it just sleeps the thread for a second. (Note: If the operation is cancelled while executing then it is allowed to finish).
- AsyncOperationIntegrationTests - a series of tests around adding operations to a suspended or live NSOperationQueue.

The Apple Class Reference states that the isAsynchronous (and isConcurrent, I suppose) property is ignored when the operation is execuited within an NSOperationQueue.  It does state that you are still responsible for the managing the state machine of the NSOperation by setting and posting KVO events that signal when isExecuting and isFinished change.

### State Transitions
 - ready -> executing -> finished
 - ready -> executing -> cancel -> finished
 - ready -> cancel -> executing -> finished
 
 ###Invalid states
 - ready -> cancelled -> finished
 This state "generates went isFinished=YES without being started by the queue it is in" and has a high amount of crashes.
 
 One thing I've noticed is that start() isn't always called (and neither is main()) if the operation is cancelled before it gets to execute.
