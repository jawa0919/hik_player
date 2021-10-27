//
//  HikViewFactory.m
//  hik_player
//
//  Created by pengrui on 2021/10/27.
//

#import "HikViewFactory.h"
#import "HikView.h"

@implementation HikViewFactory {
	NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager {
	self = [super init];
	if (self) {
		_messenger = messager;
	}
	return self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
	//args 为flutter 传过来的参数
	HikView * playerView = [[HikView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
	return playerView;
}

@end

