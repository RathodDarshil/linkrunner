#import "LinkrunnerPlugin.h"
#if __has_include(<linkrunner/linkrunner-Swift.h>)
#import <linkrunner/linkrunner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "linkrunner-Swift.h"
#endif

@implementation LinkrunnerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLinkrunnerPlugin registerWithRegistrar:registrar];
}
@end 
