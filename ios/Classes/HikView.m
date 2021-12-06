//
//  HikView.m
//  hik_player
//
//  Created by pengrui on 2021/10/27.
//

#import "HikView.h"
@import Photos;

@interface HikView ()

@property(nonatomic, strong) NSString * startTime;
@property(nonatomic, strong) NSString * endTime;

@property(nonatomic, strong) NSString * seekTime;

@property(nonatomic, strong) NSString * videoUrl;        // 预览URL
@property(nonatomic, strong) NSString * playBackUrl;     // 回放URL
@property(nonatomic, strong) HVPPlayer * player;

@property (nonatomic, assign) BOOL isPlaying;       // 播放状态
@property (nonatomic, assign) BOOL isRecording;     // 录像状态
@property (nonatomic, assign) BOOL isPlayBackBegining;      // 回放状态
@property (nonatomic, copy) NSString * recordPath;      // 录像保存路径

@end

@implementation HikView {
	// HikView 创建后的标识
	int64_t _viewId;
	NSNumber * _mPlayerStatus;
	// 消息回调
	FlutterMethodChannel* _channel;
	FlutterEventChannel * _eventChannel;
	FlutterEventSink _eventSink;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
	if ([super init]) {
		NSString* channelName = [NSString stringWithFormat:@"hik_controller_%lld", viewId];
		_channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
	   __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
         NSString* eventChannelName = @"event_isc_player";
         _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName  binaryMessenger:messenger];
         [_eventChannel setStreamHandler:self];
        
        HVPPlayer * player = [[HVPPlayer alloc] initWithPlayView:self];
        player.delegate = self;
        self.player = player;
        
        self.isRecording = NO;
        self.isPlaying = NO;
        self.isPlayBackBegining = NO;
        
        _mPlayerStatus = [NSNumber numberWithInt:IDLE];
        
    }
    return self;
}

- (void)registNotifications {
    // 注册前后台切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{

    // 开始预览
    if ([[call method] isEqualToString:@"startRealPlay"]) {
        if (_isPlayBackBegining) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //获取参数
                NSDictionary *dict = call.arguments;
                self.videoUrl = dict[@"url"];
                result([self startPlayVideo:YES]);
            });
            self.playBackUrl = @"";
            _isPlayBackBegining = NO;
        } else {
            //获取参数
            NSDictionary *dict = call.arguments;
            self.videoUrl = dict[@"url"];
            result([self startPlayVideo:YES]);
        }
        
    } if ([[call method] isEqualToString:@"changeStream"]) {        // 码流平滑切换
        
        result(@{@"ret" : @(NO),
                 @"msg" : @"iOS端暂未实现"
               });
        
    } if ([[call method] isEqualToString:@"startPlayback"]) {       // 开始回放
        if (_isPlaying) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //获取参数
                NSDictionary *dict = call.arguments;
                self.playBackUrl = dict[@"url"];
                self.startTime = dict[@"startTime"];
                self.endTime = dict[@"stopTime"];
                result([self startPlayBackVideo]);
            });
            self.videoUrl = @"";
            _isPlaying = NO;
        } else {
            //获取参数
            NSDictionary *dict = call.arguments;
            self.playBackUrl = dict[@"url"];
            self.startTime = dict[@"startTime"];
            self.endTime = dict[@"stopTime"];
            result([self startPlayBackVideo]);
        }
        
    } if ([[call method] isEqualToString:@"seekAbsPlayback"]) {         // 按绝对时间回放定位
        //获取参数
        NSDictionary * dict = call.arguments;
        self.seekTime = dict[@"seekTime"];
        result([self seekPlayBackVideo]);
        
    } if ([[call method] isEqualToString:@"getOSDTime"]) {      // 查询当前播放时间戳接口
        NSString * time = [self.player getOSDTime:nil];
        if (!time) {
            time = @"-1";
        }
        result(@{@"ret" : time});
        
    } if ([[call method] isEqualToString:@"pause"]) {       // 暂停回放
        
        result([self pausePlayBackVideo]);
        
    } if ([[call method] isEqualToString:@"resume"]) {          // 恢复回放

        result([self resumePlayBackVideo]);
        
    } if ([[call method] isEqualToString:@"stopPlay"]) {          // 停止播放
        
        result([self startPlayVideo:NO]);
        
    } if ([[call method] isEqualToString:@"startVoiceTalk"]) {          // 开启语音对讲
        
        result(@{@"ret" : @(NO),
          @"msg" : @"iOS端暂未实现"
        });
        
    } if ([[call method] isEqualToString:@"stopVoiceTalk"]) {          // 关闭语音对讲
        
        result(@{@"ret" : @(NO),
          @"msg" : @"iOS端暂未实现"
        });
        
    } if ([[call method] isEqualToString:@"capturePicture"]) {          // 抓图
        
        result([self capturePicture]);
        
    } if ([[call method] isEqualToString:@"startRecord"]) {          // 开启本地录像
        
        result([self record:YES]);
        
    } if ([[call method] isEqualToString:@"stopRecord"]) {          // 关闭本地录像
        
        result([self record:NO]);
        
    } if ([[call method] isEqualToString:@"enableSound"]) {          // 声音控制
        
        result(@{@"ret" : @(NO),
          @"msg" : @"iOS端暂未实现"
        });
        
    } if ([[call method] isEqualToString:@"onResume"]) {          //
        
        result(@{@"ret" : @(NO),
          @"msg" : @"iOS端暂未实现"
        });
        
    } if ([[call method] isEqualToString:@"onPause"]) {          //
        
        result(@{@"ret" : @(NO),
          @"msg" : @"iOS端暂未实现"
        });
    } else {
        //其他方法的回调
        result(FlutterMethodNotImplemented);
    }
}

- (nonnull UIView *)view {
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

#pragma mark - 视频相关操作
/// 开始播放视频
/// @param startType yes开始，no结束
- (NSDictionary *)startPlayVideo:(BOOL)startType {
    if (startType) {
        __block BOOL isPlaying = NO;
        // 为避免卡顿，开启预览可以放到子线程中，在应用中灵活处理
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [self.player stopPlay:nil];
            if ([self.player startRealPlay:self.videoUrl]) {
                // TODO: 开始播放
                self.isPlaying = YES;
                isPlaying = YES;
            }
        });

        return @{@"ret" : @(isPlaying),
                 @"msg" : @""
        };
    } else {
        if (_isRecording) {
            //如果在录像，先关闭录像
            [self recordVideo:NO];
        }
        BOOL isStopPlaying = NO;
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        });
        NSError * error;
        [self.player stopPlay:&error];
        if (!error) {
            isStopPlaying = YES;
            _isPlaying = NO;
        } else {
            isStopPlaying = NO;
        }
        return @{
            @"ret" : @(isStopPlaying),
            @"msg" : @""
        };
        
    }
    
}
// 抓图
- (NSDictionary *)capturePicture {
    if (!_isPlaying) {
        NSString * msg = @"未播放视频，不能抓图";
        return @{
            @"ret" : @(NO),
            @"msg" : msg
        };
    }
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
   __block NSString * code = @"0";
   __block NSString * message = @"";
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusDenied) {
            message = @"无保存图片到相册的权限，不能抓图";
            
        } else {
            NSDictionary * dic = [self capture];
            code = dic[@"code"];
            message = dic[@"msg"];
        }
        dispatch_semaphore_signal(signal);
    }];
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    return @{@"ret" : [code isEqualToString:@"0"]?@(NO):@(YES),
             @"msg" : message};
}

/// 抓拍
- (NSDictionary *)capture {
    if (!_isPlaying && !_isPlayBackBegining) {
        
        return @{
            @"code" : @"0",
            @"msg" : @"当前未播放视频"
        };
    }
    // 生成图片路径
    NSString *documentDirectorie = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [documentDirectorie stringByAppendingFormat:@"/%.f.jpg", [NSDate date].timeIntervalSince1970];
    NSError *error;
    if (![self.player capturePicture:filePath error:&error]) {
        NSString *message = [NSString stringWithFormat:@"抓图失败，错误码是 0x%08lx", error.code];
        return @{
            @"code" : @"0",
            @"msg" : message
        };
    }
    else {
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);
        __block NSString * code = @"0";
        __block NSString * message = @"";
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL URLWithString:filePath]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                message = @"抓图成功，并保存到系统相册";
                code = @"1";
            }
            else {
                message = @"保存到系统相册失败";
                code = @"0";
            }
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            dispatch_semaphore_signal(signal);
        }];
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        return @{@"code" : code,
                 @"msg" : message
        };
    }
}

// 录像
- (NSDictionary *)record:(BOOL)sender {
    if (!_isPlaying && !_isPlayBackBegining) {
        NSString * msg = @"未播放视频，不能录像";
        return @{@"ret" : @(NO),
                 @"msg" : msg
        };
    }
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    __block NSString * code = @"0";
    __block NSString * message = @"";
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        if (status == PHAuthorizationStatusDenied) {
            code = @"0";
            message = @"无保存录像到相册的权限，不能录像";
        }
        else {
            NSDictionary * dic = [self recordVideo:sender];
            code = dic[@"code"];
            message = dic[@"msg"];
        }
        dispatch_semaphore_signal(signal);
    }];
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    return @{@"ret" : [code isEqualToString:@"0"]?@(NO):@(YES),
             @"msg" : message
    };
}

/// 开始录像
/// @param recordType 类型，yes开始录像，no结束录像
- (NSDictionary *)recordVideo:(BOOL)recordType {
    if (!_isPlaying && !_isPlayBackBegining) {
        NSString * msg = @"未播放视频，不能录像";
        return @{@"code" : @"0",
                 @"msg" : msg
        };
    }
    NSError *error;
    // 开始录像
    if (recordType) {
        NSString * code = @"0";
        NSString * message = @"";
        // 生成图片路径
        NSString *documentDirectorie = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *filePath = [documentDirectorie stringByAppendingFormat:@"/%.f.mp4", [NSDate date].timeIntervalSince1970];
        _recordPath = [filePath copy];
        if ([self.player startRecord:filePath error:&error]) {
            _isRecording = YES;
            // TODO:开始录像，改变按钮状态
            code = @"1";
            message = @"";
        } else {
            message = [NSString stringWithFormat:@"开始录像失败，错误码是 0x%08lx", error.code];
            code = @"0";
        }
        return @{@"code" : code,
                 @"msg" : message
        };
    }
    if (!_isRecording) {
        NSString * msg = @"当前录像已经停止，无法停止录像";
        return @{@"code" : @"0",
                 @"msg" : msg
        };
    }
    // 停止录像
    if ([self.player stopRecord:&error]) {
        _isRecording = NO;
        
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);
        __block NSString * code = @"0";
        __block NSString * message = @"";
        //可在自定义recordPath路径下取录像文件
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:_recordPath]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                message = @"录像成功，并保存到系统相册";
                code = @"1";
            } else {
                message = @"保存到系统相册失败";
                code = @"0";
            }
            dispatch_semaphore_signal(signal);
        }];
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        return @{@"code" : code,
                 @"msg" : message
        };
    }
    else {
        NSString *message = [NSString stringWithFormat:@"停止录像失败，错误码是 0x%08lx", error.code];
        return @{@"code" : @"0",
                 @"msg" : message
        };
    }
}


/// 开始回放
- (NSDictionary *)startPlayBackVideo {
    
    __block BOOL isPlaying = NO;
    // 为避免卡顿，开启预览可以放到子线程中，在应用中灵活处理
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        double start = [self.startTime doubleValue];
        double end = [self.endTime doubleValue];
        [self.player stopPlay:nil];
        BOOL ret = [self.player startPlayback:self.playBackUrl startTime:start endTime:end];
        if (ret) {
            // TODO: 开始播放
            self.isPlayBackBegining = YES;
            isPlaying = YES;

        } else {

        }
    });
    return @{@"ret" : @(isPlaying),
             @"msg" : @""
    };
}

/// 指定时间快进
- (NSDictionary *)seekPlayBackVideo {
    __block BOOL isSeek = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        BOOL ret = [self.player seekToTime:[self.seekTime doubleValue]];
        if (ret) {
            isSeek = YES;
        }
    });
    
    return @{@"ret" : @(isSeek),
             @"msg" : @""
    };
}

/// 暂停回放
- (NSDictionary *)pausePlayBackVideo {
    __block BOOL isStop = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSError * error;
        BOOL ret = [self.player pause:&error];
        if (ret) {
            isStop = YES;
        }
    });
    return @{@"ret" : @(isStop),
             @"msg" : @""
    };
}

/// 恢复回放
- (NSDictionary *)resumePlayBackVideo {
    __block BOOL isResume = NO;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSError * error;
        BOOL ret = [self.player resume:&error];
        if (ret) {
            isResume = YES;
        }
    });
    return @{@"ret" : @(isResume),
             @"msg" : @""
    };
}

/// 停止预览或回放
- (void)stopPlayVideo {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSError * error;
        [self.player stopPlay:&error];
        if (!error) {
            _isPlaying = NO;
            _isPlayBackBegining = NO;
        } else {
            NSLog(@"停止播放失败：%@", error);
        }
    });
}

#pragma mark - HVPPlayerDelegate
- (void)player:(HVPPlayer *)player playStatus:(HVPPlayStatus)playStatus errorCode:(HVPErrorCode)errorCode {
    
    self.isPlaying = NO;
    NSString *message;
    // 预览时，没有HVPPlayStatusFinish状态，该状态表明录像片段已播放完
    switch (playStatus) {
        case HVPPlayStatusSuccess: {
            self.isPlaying = YES;
            _mPlayerStatus = [NSNumber numberWithInt:SUCCESS];
            // 默认开启声音
            [self.player enableSound:YES error:nil];
        }
            break;
        case HVPPlayStatusFailure: {
            _mPlayerStatus = [NSNumber numberWithInt:FAILED];
            if (errorCode == HVPErrorCodeURLInvalid) {
                message = @"URL输入错误请检查URL或者URL已失效请更换URL";
            } else {
                message = [NSString stringWithFormat:@"开启预览失败, 错误码是 : 0x%08lx", errorCode];
            }
            if (self.isRecording) {
                //如果在录像，先关闭录像
                [self recordVideo:NO];
            }
            // 关闭播放
            NSError * error;
            [self.player stopPlay:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
            break;
        case HVPPlayStatusException: {
            // 预览过程中出现异常, 可能是取流中断，可能是其他原因导致的，具体根据错误码进行区分
            // 做一些提示操作
            _mPlayerStatus = [NSNumber numberWithInt:EXCEPTION];
            message = [NSString stringWithFormat:@"播放异常, 错误码是 : 0x%08lx", errorCode];
            if (self.isRecording) {
                //如果在录像，先关闭录像
                [self recordVideo:NO];
            }
            // 关闭播放
            [self.player stopPlay:nil];
        }
            break;
        case HVPPlayStatusFinish: {
            // 预览过程中出现异常, 可能是取流中断，可能是其他原因导致的，具体根据错误码进行区分
            // 做一些提示操作
            _mPlayerStatus = [NSNumber numberWithInt:FINISH];
            message = [NSString stringWithFormat:@"播放完成, 错误码是 : 0x%08lx", errorCode];
            if (self.isRecording) {
                //如果在录像，先关闭录像
                [self recordVideo:NO];
            }
            // 关闭播放
            [self.player stopPlay:nil];
        }
            break;
            
        default:
            break;
    }
    NSDictionary * ret = @{@"status" : _mPlayerStatus};
    [_channel invokeMethod:@"onPlayerStatusCallback" arguments:ret];
}

#pragma mark - Notification Method
- (void)applicationWillResignActive {
    if (_isRecording) {
        [self recordVideo:NO];
    }
    if (_isPlaying) {
        [self startPlayVideo:NO];
    }
    if (_isPlayBackBegining) {
        [self pausePlayBackVideo];
    }
}

- (void)applicationDidBecomeActive {
    if (self.videoUrl.length > 0) {
        // 为避免卡顿，开启预览可以放到子线程中，在应用中灵活处理
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            if ([self.player startRealPlay:self.videoUrl]) {
                self.isPlaying = YES;
            }
        });
    }
    if (_isPlayBackBegining) {
        [self resumePlayBackVideo];
    }
}

@end

