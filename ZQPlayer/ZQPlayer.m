//
//  ZQPlayer.m
//  ZQPlayer
//
//  Created by wang on 2018/3/30.
//  Copyright © 2018年 qigge. All rights reserved.
//

#import "ZQPlayer.h"

@interface ZQPlayer ()

// 是否正在播放
@property (nonatomic, assign) BOOL isPlaying;
// 是否在缓冲
@property (nonatomic, assign) BOOL isBuffering;

/** player 时间监听 */
@property (nonatomic,strong) id playerTimeObserver;

@end

@implementation ZQPlayer

#pragma mark - Public Method
- (instancetype)init {
    if (self = [super init]) {
        
        // 打断
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategorySoloAmbient
         error: nil];
        
        // app退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];

        _isPlaying = NO;
        _isBuffering = YES;
        
        _player = [AVPlayer playerWithPlayerItem:_playerItme];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.backgroundColor = [UIColor clearColor].CGColor;

    }
    return self;
}
- (instancetype)initWithUrl:(NSString *)url {
    if (self = [self init]) {
        [self nextWithUrl:url];
    }
    return self;
}

- (void)nextWithUrl:(NSString *)url {
    [_player pause];
    // 移除之前的时间监听
    [self removeTimeObserver];
    
    if (_playerItme) {
        [_playerItme removeObserver:self forKeyPath:@"status"];
        [_playerItme removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItme removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItme removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItme];
        _playerItme = nil;
    }
    if (!url) {
        return;
    }
    _playUrl = url;
    
    NSURL *videoUrl;
    if ([url containsString:@"http"]) {
        videoUrl = [self translateIllegalCharacterWtihUrlStr:url];
    }else {
        videoUrl = [NSURL fileURLWithPath:url];
    }
    _playerItme = [AVPlayerItem playerItemWithURL:videoUrl];
    if (@available(iOS 9.0, *)) {
        _playerItme.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    } 
    [_player replaceCurrentItemWithPlayerItem:_playerItme];
    
    // AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItme];
    
    // 监听播放状态
    [_playerItme addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听loadedTimeRanges属性
    [_playerItme addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is empty
    [_playerItme addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is good to go again.
    [_playerItme addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    _player.rate=1.0;
    
    if (_isPlaying) {
        [_player play];
    }else {
        [_player pause];
    }
}

#pragma mark - 公开的方法
- (void)play {
    if (!_isPlaying) {
        if (!_playerItme) {
            [self nextWithUrl:_playUrl];
        }
        [_player play];
        _isPlaying = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
            [self.delegate ZQPlayerStateChange:self state:ZQPlayerStatePlaying];
        }
    }
}
- (void)pause {
    if (_isPlaying) {
        _isPlaying = NO;
        [_player pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
            [self.delegate ZQPlayerStateChange:self state:ZQPlayerStatePause];
        }
    }
}

- (void)stop {
    _isPlaying = NO;
    [_player pause];
    // 移除之前的时间监听
    [self removeTimeObserver];
    
    if (_playerItme) {
        [_playerItme removeObserver:self forKeyPath:@"status"];
        [_playerItme removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItme removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItme removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItme];
        _playerItme = nil;
    }
    [_player replaceCurrentItemWithPlayerItem:_playerItme];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
        [self.delegate ZQPlayerStateChange:self state:ZQPlayerStateStop];
    }
}



#pragma mark - Priva Method
//设置播放进度和时间
-(void)setTheProgressOfPlayTime {
    self.timeInterval   = CMTimeGetSeconds(_playerItme.asset.duration);
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerTotalTime:totalTime:)]) {
        [self.delegate ZQPlayerTotalTime:self totalTime:self.timeInterval];
    }
    [self removeTimeObserver];
     __weak typeof(self) weakSelf = self;
    _playerTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.isPlaying) {
            CGFloat currentTime = CMTimeGetSeconds(time);
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ZQPlayerCurrentTime:currentTime:)]) {
                [weakSelf.delegate ZQPlayerCurrentTime:weakSelf currentTime:currentTime];
            }
        }
    }];
}
- (void)removeTimeObserver {
    if (_playerTimeObserver) {
        @try {
            [_player removeTimeObserver:_playerTimeObserver];
        }@catch (id e) {
            
        }@finally {
            _playerTimeObserver = nil;
        }
    }
}
- (NSURL *)translateIllegalCharacterWtihUrlStr:(NSString *)yourUrl{
    //如果链接中存在中文或某些特殊字符，需要通过以下代码转译
    yourUrl = [yourUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *encodedString = [yourUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:encodedString];
}

#pragma mark - NSNotification

- (void)moviePlayDidEnd:(NSNotification *)noti {
    [_player seekToTime:kCMTimeZero];
    _isPlaying = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
        [self.delegate ZQPlayerStateChange:self state:ZQPlayerStateStop];
    }
}
// 应用退到后台
- (void)appDidEnterBackground {
    [self pause];
}
// 应用进入前台
- (void)appDidEnterPlayGround {

}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _playerItme) {
        if ([keyPath isEqualToString:@"status"]) {
            if (_playerItme.status == AVPlayerStatusReadyToPlay) {
                [self setTheProgressOfPlayTime];
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
                    [self.delegate ZQPlayerStateChange:self state:ZQPlayerStateReadyToPlay];
                }
            }else if (_playerItme.status == AVPlayerStatusFailed) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
                    [self.delegate ZQPlayerStateChange:self state:ZQPlayerStateFailed];
                }
                [self stop];
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            CMTimeRange range = [_playerItme.loadedTimeRanges.firstObject CMTimeRangeValue];
            CGFloat loadSeconds = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerLoadTime:loadTime:)]) {
                [self.delegate ZQPlayerLoadTime:self loadTime:loadSeconds];
            }
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (!_playerItme.playbackLikelyToKeepUp) {
                _isBuffering = YES;
            }else {
                _isBuffering = NO;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(ZQPlayerStateChange:state:)]) {
                [self.delegate ZQPlayerStateChange:self state:_isBuffering?ZQPlayerStateBufferEmpty:ZQPlayerStateKeepUp];
            }
        }
    }
}


#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.playerItme removeObserver:self forKeyPath:@"status"];
    [self.playerItme removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItme removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItme removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    // 恢复其他音频
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}


@end
