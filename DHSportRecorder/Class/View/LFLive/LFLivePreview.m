//
//  LFLivePreview.m
//  LFLiveKit
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

//
// https://github.com/LaiFengiOS/LFLiveKit/tree/master
// https://github.com/BradLarson/GPUImage
//

#import "LFLivePreview.h"
#import "UIControl+YYAdd.h"
#import "UIView+YYAdd.h"
#import "LFLiveKit.h"

inline static NSString* formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }
    
    if (bytes <= 0) {
        return @"0 KB/s";
    }
    
    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface LFLivePreview () <LFLiveSessionDelegate>

@property (nonatomic, strong) LFLiveDebug* debugInfo;
@property (nonatomic, strong) LFLiveSession* session;

@property (nonatomic, strong) UILabel* stateLabel;
@property (nonatomic, copy) NSString* streamURL;

@end

@implementation LFLivePreview

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self addSubview:[self stateLabel]];
    return self;
}

- (void) prepareForUsing {
    [self requestAccessForVideo];
    [self requestAccessForAudio];
}

#pragma mark -- Public Method
- (void) requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // Диалог Лицензия не появляется, запуск Лицензия
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning: YES];
                    });
                }
            }];
        } break;
        case AVAuthorizationStatusAuthorized: {
            // Он открыл разрешено продолжать
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning: YES];
            });
        } break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // Пользователь явно отказано в разрешении, или не может получить доступ к устройству камеры
            break;
        default:
            break;
    }
}

- (void) requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
        } break;
        case AVAuthorizationStatusAuthorized:
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        default:
            break;
    }
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor greenColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:20.f];
    }
    return _stateLabel;
}

#pragma mark -- LFStreamingSessionDelegate
- (void) liveSession: (nullable LFLiveSession*) session liveStateDidChange: (LFLiveState) state {
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
        case LFLiveReady:
            _stateLabel.text = @"No connect";
            break;
        case LFLivePending:
            _stateLabel.text = @"Connecting...";
            break;
        case LFLiveStart:
            _stateLabel.text = @"Connected";
            break;
        case LFLiveError:
            _stateLabel.text = @"Connection error";
            break;
        case LFLiveStop:
            _stateLabel.text = @"No Connected";
            break;
        default:
            break;
    }
}

- (void) liveSession: (nullable LFLiveSession*) session debugInfo: (nullable LFLiveDebug*)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

- (void) liveSession: (nullable LFLiveSession*) session errorCode: (LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
    if (!_session) {
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(480, 854);
        videoConfiguration.videoBitRate = 800 * 1024;
        videoConfiguration.videoMinBitRate = 500 * 1024;
        videoConfiguration.videoMaxBitRate = 1000 * 1024;
        videoConfiguration.videoFrameRate = 30;
        videoConfiguration.outputImageOrientation = UIDeviceOrientationPortrait;
        videoConfiguration.autorotate = NO;

        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        _session.delegate = self;
        _session.showDebugInfo = NO;
        _session.preView = self;
    }
    return _session;
}


- (void) changeCameraPosition {
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (BOOL) changeBeauty {
    self.session.beautyFace = !self.session.beautyFace;
    return !self.session.beautyFace;
}

- (void) startPublishingWithStreamURL: (NSString*) streamURL {
    LFLiveStreamInfo* stream = [LFLiveStreamInfo new];
    stream.url = streamURL;
    [self.session startLive: stream];
}

- (void) stopPublishing {
    [self.session stopLive];
}

@end
