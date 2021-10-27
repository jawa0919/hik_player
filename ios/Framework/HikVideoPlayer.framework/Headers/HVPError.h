//
//  HikVideoPlayerError.m
//  HikVideoPlayer
//
//  Created by westke on 2018/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const HVPErrorDomain;

/**
 此处定义的为常用错误码，只覆盖服务端某些常用的错误码，
 如果碰到不常用的，请根据具体错误码去对应服务中查询
 */
typedef NS_ERROR_ENUM(HVPErrorDomain, HVPErrorCode) {
	/** 未出错 */
	HVPErrorCodeSuccess = 0,
	
	/** SDK未初始化 */
	HVPErrorCodeSDKNotInit,
	
	/** 创建的Player数量超过限制，最大支持32路同时播放 */
	HVPErrorCodePlayersExceedLimit,
	
	/** 播放器流头识别失败 */
	HVPErrorCodeOpenStreamFailed,
	
	/** 播放器播放失败 */
	HVPErrorCodePlayFailed,
	
	/** 创建取流session失败 */
	HVPErrorCodeCreateFetchStreamSessionFailed,
	
	/** 取流URL已失效或者取流URL不对，请检查取流URL */
	HVPErrorCodeURLInvalid,
	
	/** 取流超时 */
	HVPErrorCodeFetchStreamTimeOut,
	
	/** 视频解码失败，请检查查询url时expand参数值是否传对 */
	HVPErrorCodeVideoDecodeFailed,
	
	/** 取流异常断开链接 */
	HVPErrorCodeFetchStreamDisconnect,
	
	/** 播放器未播放 */
	HVPErrorCodeNotPlaying,
	
	/** 文件路径不能为空 */
	HVPErrorCodeFilePathCanNotBeNil,
	
	/** 分配图片内存失败 */
	HVPErrorCodeAllocPictureMemoryFailed,
	
	/** 从播放的视频中获取jpeg图片失败 */
	HVPErrorCodeGetJPEGFailed,
	
	/**  图片保存失败 */
	HVPErrorCodeSavePictureFailed,
	
	/** 创建音频编解码引擎失败 */
	HVPErrorCodeCreateAudioEngineFailed,
	
	/** 音频编解码引擎打开对讲失败 */
	HVPErrorCodeAudioEngineLibOpenFailed,
	
	/** 设置音频参数失败 */
	HVPErrorCodeSetAudioParamFailed,
	
	/** 设置音频数据回调失败 */
	HVPErrorCodeSetAudioDataCallBackFailed,
	
	/** 音频播放失败 */
	HVPErrorCodeAudioPlayFailed,
	
	/** 录音失败 */
	HVPErrorCodeAudioRecordFailed,
	
	/** 音频缓冲区初始化失败 */
	HVPErrorCodeAudioBufferInitFailed,
	
	/** 设备音频格式不支持 */
	HVPErrorCodeDeviceAudioTypeNotSupport,
	
	/** 当前设备正在对讲中(在和其他手机客户端对讲)，请稍等重试 */
	HVPErrorCodeIsIntercoming,
	
	/** 未开启对讲 */
	HVPErrorCodeNotIntercoming
	
	/**0x01b0----，0x01b0开头的错误码是视频联网共享服务相关的错误码-*/
	/**0x0173----，0x0173开头的错误码是媒体网关服务和客户端相关的错误码-*/
	/**0x0180----，0x018开头的错误码是视频点播服务相关的错误码------------*/
	/**0x0190----，0x019开头的错误码是设置接入服务相关的错误码------------*/
};

NS_ASSUME_NONNULL_END
