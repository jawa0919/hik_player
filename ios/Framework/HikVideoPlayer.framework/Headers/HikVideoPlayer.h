//
//  HikVideoPlayer.h
//  HikVideoPlayer
//
//  Created by westke on 2018/9/12.
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import <HikVideoPlayer/HVPError.h>
#import <HikVideoPlayer/HVPConst.h>
#import <HikVideoPlayer/HVPPlayer.h>
#import <HikVideoPlayer/HVPVoiceIntercomClient.h>

FOUNDATION_EXPORT double HikVideoPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char HikVideoPlayerVersionString[];
