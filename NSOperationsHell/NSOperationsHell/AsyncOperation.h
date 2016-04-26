#import <Foundation/Foundation.h>

@interface AsyncOperation : NSOperation

// Helpers to post KVO...

- (void)transitionToStartedState;
- (void)transitionToFinishedState;

@end
