#import "HikPlayerPlugin.h"
#import "HikViewFactory.h"

@implementation HikPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
	FlutterMethodChannel* channel = [FlutterMethodChannel
	                                 methodChannelWithName:@"hik_player"
	                                 binaryMessenger:[registrar messenger]];
	HikPlayerPlugin* instance = [[HikPlayerPlugin alloc] init];
	[registrar addMethodCallDelegate:instance channel:channel];
	[registrar registerViewFactory:[[HikViewFactory alloc] initWithMessenger:registrar.messenger] withId:@"hik_player.viewType"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
	if ([@"getPlatformVersion" isEqualToString:call.method]) {
		result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
	} else {
		result(FlutterMethodNotImplemented);
	}
}

@end
