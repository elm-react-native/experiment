#import "AppDelegate.h"
#import "RCTAppDependencyProvider.h"
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (NSURL *)debugBundleURL
{
  return [RCTBundleURLProvider jsBundleURLForBundleRoot:@"index"
                                           packagerHost:@"localhost:8081"
                                              enableDev:YES
                                     enableMinification:NO
                                        inlineSourceMap:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"Plex";
  self.dependencyProvider = [RCTAppDependencyProvider new];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [self debugBundleURL];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (NSURL *)bundleURL
{
#if DEBUG
  return [self debugBundleURL];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
