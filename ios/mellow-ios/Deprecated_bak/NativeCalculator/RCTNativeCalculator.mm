//
//  RCTNativeCalculator.m
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/01/2025.
//

#import "RCTNativeCalculator.h"
#import <RCTAppDelegate.h>
#import "mellow_ios-Swift.h"

@implementation RCTNativeCalculator {
    BOOL didRegisterObserver;
}

RCT_EXPORT_MODULE()

- (void)add:(double)a b:(double)b resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSNumber *result = [[NSNumber alloc] initWithInteger:a+b];
    resolve(result);
    
    // On the first call, set up the observer and start the timer.
//    if (!didRegisterObserver) {
        didRegisterObserver = YES;
        
        __weak RCTNativeCalculator* weakSelf = self;
        // Register an observer that listens for the counter updates in RNTestEmiter
        [RNTestEmiter.shared registerObserver:^(NSInteger updatedCounterValue) {
            [weakSelf emitOnValueChanged:@(updatedCounterValue)];
        }];
        
        // Start the timer in RNTestEmiter so it begins incrementing and notifying observers.
//        [RNTestEmiter.shared startTimer];
//    }
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}

-(NSString *)getHelloMessage {
    return @"Hello form Objective-C++";
}

@end
