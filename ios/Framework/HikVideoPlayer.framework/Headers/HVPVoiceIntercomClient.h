//
//  HVPVoiceIntercomClient.h
//  HikVideoPlayer
//
//  Created by westke on 2018/12/3.
//

#import <Foundation/Foundation.h>

#import "HVPError.h"
#import "HVPConst.h"

@protocol HVPVoiceIntercomClientDelegate;

@interface HVPVoiceIntercomClient : NSObject

@property (nonatomic, weak) id<HVPVoiceIntercomClientDelegate>         	delegate;
@property (nonatomic, assign, readonly) BOOL							isIntercoming;

/**
 开启日志，debug下设置为yes可以查看取流日志
 */
@property (nonatomic, assign) BOOL         				  logEnabled;

/**
 开启语音对讲
 @param rtspUrl 对讲通道
 */
- (BOOL)startVoiceIntercom:(NSString *)rtspUrl;

/**
 关闭语音对讲
 */
- (BOOL)stopVoiceIntercom:(NSError **)error;

@end

@protocol HVPVoiceIntercomClientDelegate <NSObject>

/**
 开启语音对讲是个异步过程，比如取设备端的语音流，需要先建立链接，建立成功并不代表成功了，如果取流超时，或者其他原因导致失败仍表示开启失败
 */
- (void)intercomClient:(HVPVoiceIntercomClient *)intercomClient playStatus:(HVPPlayStatus)playStatus errorCode:(HVPErrorCode)errorCode;

@end
