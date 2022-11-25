#import "FlutterSharingIntentPlugin.h"
#if __has_include(<flutter_sharing_intent/flutter_sharing_intent-Swift.h>)
#import <flutter_sharing_intent/flutter_sharing_intent-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_sharing_intent-Swift.h"
#endif

@implementation FlutterSharingIntentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSharingIntentPlugin registerWithRegistrar:registrar];
}
@end
