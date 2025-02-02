//
//  MRNLearnConnector.m
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 29/01/2025.
//

#import "RCTNativeLearnConnector.h"
#import <RCTAppDelegate.h>
#import "mellow_ios-Swift.h"

@implementation RCTNativeLearnConnector

RCT_EXPORT_MODULE()

- (id) init {
  if (self = [super init]) {
      // Init tracker to emit reset event if needed
      __weak RCTNativeLearnConnector* weakSelf = self;
      [[LearnConnector shared] setResetHandler:^{
          [weakSelf emitOnRestState];
      }];
  }
  return self;
}

- (void)onCourseStarted:(NSString *)course {
    [[LearnConnector shared] onCourseStarted];
}

- (void)onCourseEnded:(NSString *)course {
    [[LearnConnector shared] onCourseEnded];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeLearnConnectorSpecJSI>(params);
}

@end
