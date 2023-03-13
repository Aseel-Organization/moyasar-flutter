//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<pay_ios/PayPlugin.h>)
#import <pay_ios/PayPlugin.h>
#else
@import pay_ios;
#endif

#if __has_include(<webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PayPlugin registerWithRegistrar:[registry registrarForPlugin:@"PayPlugin"]];
  [FLTWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTWebViewFlutterPlugin"]];
}

@end
