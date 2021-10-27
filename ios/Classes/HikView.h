//
//  HikView.h
//  Pods
//
//  Created by pengrui on 2021/10/27.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

#import <HikVideoPlayer/HVPError.h>
#import <HikVideoPlayer/HVPPlayer.h>
#import <HikVideoPlayer/HikVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface HikView : UIView<FlutterPlatformView, FlutterStreamHandler, HVPPlayerDelegate>


-(instancetype)initWithWithFrame:(CGRect)frame
        viewIdentifier:(int64_t)viewId
        arguments:(id _Nullable)args
        binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END


typedef NS_ENUM (NSUInteger, WFPTZControlDirection) {
	WFPTZControlDirectionUp,            // 上
	WFPTZControlDirectionDown,          // 下
	WFPTZControlDirectionLeft,          // 左
	WFPTZControlDirectionRight,         // 右
	WFPTZControlDirectionCenter,        // 中
};

typedef NS_ENUM (NSUInteger, WFHikVideoStatus) {
	IDLE,                   // 闲置状态
	LOADING,                // 加载中状态
	SUCCESS,                // 播放成功
	STOPPING,               // 暂时停止播放
	FAILED,                 // 播放失败
	EXCEPTION,              // 播放过程中出现异常
	FINISH,                 // 回放结束
};

