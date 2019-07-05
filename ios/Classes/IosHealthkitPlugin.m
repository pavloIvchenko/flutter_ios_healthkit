#import "IosHealthkitPlugin.h"
#import <ios_healthkit/ios_healthkit-Swift.h>

@implementation IosHealthkitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIosHealthkitPlugin registerWithRegistrar:registrar];
}
@end
