# ios-nsoperation-hell

This is an example project that demonstates concurrent/asynchronous NSOperations.  I haven't found a good tutorial that went into detail about the life cycle of an NSOperation when it is Asynchronous.

### concurrent/asynchronous requirements (from the official class reference)
- override start()
- override isExecuting() and post appropriate kvo events when state changes
- override isFinished() and post appropriate kvo events when state changes
- override isConcurrent()/isAsynchronous()

### about this code base
- AsyncOperation handles the KVO eventing for the two state transitions that I _think_ we care about: executing and finishing.
- SleepingAsyncOperation is an operation that manages its own internal state.  If the operation gets to actually execute it just sleeps the thread for a second. (Note: If the operation is cancelled while executing then it is allowed to finish).
- AsyncOperationIntegrationTests - a series of tests around adding operations to a suspended or live NSOperationQueue.

The Apple Class Reference states that the isAsynchronous (and isConcurrent, I suppose) property is ignored when the operation is execuited within an NSOperationQueue.  It does state that you are still responsible for the managing the state machine of the NSOperation by setting and posting KVO events that signal when isExecuting and isFinished change.

### State Transitions
- ready -> executing -> finished
- ready -> executing -> cancel -> finished
- ready -> cancelled -> finished

### in a nutshell
- keep whatever work the operation is doing as small as possible to avoid pain when trying to figure out how to cancel
- start() is the entry point.  You must check for self.isCancelled and KVO out or start the work of the operation.
- every loop, callback/delegate/observer event, etc, must be wrapped in self.isCancelled so that the operation does not do any more work after it is cancelled and is in the process of exiting.
- when the async unit of work finishes set isFinished=YES and KVO out to signal the operation is finished.  Do any cleanup work to prevent retain cycles.
- cancel()'s first line is [super cancel], then if self.isExecuting it optionally will inform any worker objects to cancel.  set isFinished=YES and KVO out when appropriate (usually when the async unit of work has reached some stopping point) 

## Possible Undocumented Requirements For Not Crashing (aka I'm filing a RADAR)

From the class docs:
```
Responding to the Cancel Command
If you implement a custom start method, that method should include early checks for cancellation and behave appropriately. Your custom start method must be prepared to handle this type of early cancellation.
```

If the operation is concurrent/asynchronous (or you decide to manage state because the docs say these properties are ignored...) if the operation is cancelled BEFORE the queue runs it (!self.isExecuting) then in start() you can set isFinished and perform the associated kvo events.  This seems to prevent any crashes and allows the operation to complete just fine.  It seems that the class reference does mention that you need to handle early cancellation in start but it fails to note that posting isExecuting=YES and posting those KVO events will trigger crashes.  You can (depending on your operation and what it is doing) set isFinished=YES and post those KVO events without any harm that I have noticed.  Big pro tip: pay attention to how you handle the case of "my operation was cancelled before the queue started it."
