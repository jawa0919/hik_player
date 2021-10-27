//
//  HVPPlayer.h
//  HikVideoPlayer
//
//  Created by westke on 2018/9/6.
//

#import <Foundation/Foundation.h>

#import "HVPError.h"
#import "HVPConst.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HVPPlayerDelegate;

@interface HVPPlayer : NSObject

@property (nonatomic, weak) id<HVPPlayerDelegate>         delegate;
/**
 开启日志，debug下设置为yes可以查看取流日志
 */
@property (nonatomic, assign) BOOL         				  logEnabled;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

/**
 根据监控点信息和播放视图初始化player，此player通过mgc取流，支持预览和回放
 
 @param playView 播放视图
 @return 播放器
 */

+ (instancetype)playerWithPlayView:(nonnull UIView *)playView;

/**
 根据监控点信息和播放视图初始化player，此player通过mgc取流，支持预览和回放
 
 @param playView 播放视图
 @return 播放器
 */
- (instancetype)initWithPlayView:(nonnull UIView *)playView;

/**
 开启预览

 @param rtspUrl 取流URL
 */
- (BOOL)startRealPlay:(nonnull NSString *)rtspUrl;

/**
 开启录像回放

 @param rtspUrl 取流URL
 @param startTime 开始时间
 @param endTime 结束时间
 */
- (BOOL)startPlayback:(nonnull NSString *)rtspUrl startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

/**
 停止取流和播放
 */
- (BOOL)stopPlay:(NSError **)error;

/**
 暂停回放
 */
- (BOOL)pause:(NSError **)error;

/**
 恢复回放
 */
- (BOOL)resume:(NSError **)error;

/**
 指定播放时间

 @param time 指定时间
 */
- (BOOL)seekToTime:(NSTimeInterval)time;

/**
 开启和关闭声音
 
 @param isEnable YES为开启，NO为关闭
 */
- (BOOL)enableSound:(BOOL)isEnable error:(NSError **)error;

/**
 抓图

 @param filePath 指定保存路径（包括文件名）
 */
- (BOOL)capturePicture:(NSString *)filePath error:(NSError **)error;


/// 电子放大  
/// @param specificRect 指定区域
- (BOOL)openDigitalZoom:(CGRect)specificRect;

/// 关闭电子放大
- (BOOL)closeDigitalZoom;

/**
 获取视频中屏幕显示时间,以字符串的形式
 */
- (NSString *)getOSDTime:(NSError **)error;

/**
 开始录像

 @param filePath 录像保存路径
 */
- (BOOL)startRecord:(NSString *)filePath error:(NSError **)error;

/**
 结束录像
 */
- (BOOL)stopRecord:(NSError **)error;


/// 设置解码方式 Yes：硬解码 No：软解码
/// @param isHardDecode 是否硬解码
- (void)setHardDecodePlay:(BOOL)isHardDecode;


/// 设置是否显示智能信息
/// @param isSmartDetect 是否显示智能信息
- (void)setSmartDetect:(BOOL)isSmartDetect;

@end

@protocol HVPPlayerDelegate <NSObject>

@optional

/**
 播放状态回调

 @param player 当前播放器
 @param playStatus 播放状态
 @param errorCode 错误码
 */
- (void)player:(HVPPlayer *)player playStatus:(HVPPlayStatus)playStatus errorCode:(HVPErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END
