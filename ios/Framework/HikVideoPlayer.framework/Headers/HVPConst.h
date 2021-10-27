//
//  HVPConst.h
//  Pods
//
//  Created by westke on 2018/12/10.
//

#ifndef HVPConst_h
#define HVPConst_h

#import <Foundation/Foundation.h>

/**
 播放器播放状态
 
 - HVPPlayStatusSuccess: 播放成功(包括开启预览、开启回放、回放seek操作，开启语音对讲)
 - HVPPlayStatusFailure: 播放失败(包括开启预览、开启回放、回放seek操作，开启语音对讲)
 - HVPPlayStatusException: 播放中异常（预览、回放、对讲）
 - HVPPlayStatusFinish: 播放结束（回放）
 */
typedef NS_ENUM(NSUInteger, HVPPlayStatus) {
	HVPPlayStatusSuccess,
	HVPPlayStatusFailure,
	HVPPlayStatusException,
	HVPPlayStatusFinish
};

/**
 解码方式
 
 - HIKVideoDecodeMethodHard: 硬解码
 - HIKVideoDecodeMethodSoft: 软解码
 */
typedef NS_ENUM(NSUInteger, HVPVideoDecodeMethod) {
    HVPVideoDecodeMethodHard = 0,
    HVPVideoDecodeMethodSoft
};

#endif /* HVPConst_h */
