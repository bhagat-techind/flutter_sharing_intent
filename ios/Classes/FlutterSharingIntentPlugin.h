// Keep this header free of Flutter imports so Xcode 16's explicit module
// scanner doesn't fail to resolve the Flutter framework at pre-scan time.
// The full Flutter.h import lives in FlutterSharingIntentPlugin.m instead.
#import <Foundation/Foundation.h>

@protocol FlutterPluginRegistrar;

@interface FlutterSharingIntentPlugin : NSObject

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

@end
