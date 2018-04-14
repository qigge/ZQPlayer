# ZQPlayer
iOS AVPlayer封装（网络视频、音频播放器）

## 简述

https://github.com/qigge/ZQPlayer

[ZQPlayer](https://github.com/qigge/ZQPlayer
) 是一个基于AVPlayer封装的视频、音频播放器，视频播放效果图如下
![竖屏效果](https://upload-images.jianshu.io/upload_images/2268074-1df3c0d7c0e50857.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

![横屏效果](https://upload-images.jianshu.io/upload_images/2268074-8a4bf9816a5d34d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

## 安装
### 1.手动添加：

*   1.将ZQPlayer文件夹添加到工程目录中

*   2.导入ZQPlayerMaskView.h （视频播放）

### 2.CocoaPods：

*   1.在Podfile中添加 ```pod 'ZQPlayer'```

*   2.执行pod install或pod update

*   3.导入ZQPlayerMaskView.h （视频播放）
 

## ZQPlayer 使用

### 视频播放使用

初始化
```
    _playerMaskView = [[ZQPlayerMaskView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width*0.56)];
    _playerMaskView.delegate = self;
    _playerMaskView.isWiFi = YES; // 是否允许自动加载，
    [self.view addSubview:_playerMaskView];
    
    // 网络视频
    NSString *videoUrl = @"http://183.60.197.29/17/q/t/v/w/qtvwspkejwgqjqeywjfowzdjcjvjzs/hc.yinyuetai.com/A0780162B98038FBED45554E85720E53.mp4?sc=e9bad1bb86f52b6f&br=781&vid=3192743&aid=38959&area=KR&vst=2&ptp=mv&rd=yinyuetai.com";
    // 本地视频
    // NSString *videoUrl = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    [_playerMaskView playWithVideoUrl:videoUrl]; 
    // 布局 
    [_playerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(_playerMaskView.mas_width).multipliedBy(0.56);
    }];
```
全屏操作涉及到了屏幕旋转，需要在当前的ViewController中加入如下代码，具体可以参考这篇文章[iOS 获取屏幕方向，和强制屏幕旋转](https://www.jianshu.com/p/531b7eed7e4b)
```
#pragma mark - 屏幕旋转
//是否自动旋转,返回YES可以自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
//这个是返回优先方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
// 全屏需要重写方法 
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator  {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait || orientation
        == UIDeviceOrientationPortraitUpsideDown) {
        // 隐藏导航栏
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [_playerMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(100);;
            make.height.equalTo(_playerMaskView.mas_width).multipliedBy(0.56);
        }];
    }else {
        // 显示导航栏
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_playerMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
```

## 音频播放

```
    // 音频播放
    NSString *mp3Url = @"http://m10.music.126.net/20180414124141/e3e56fbce547d0fabda73f65db249437/ymusic/1f36/af3d/60a8/f7ac35fcd56465570b2031b93edd2546.mp3";
    _audioPlayer = [[ZQPlayer alloc] initWithUrl:mp3Url];
    [_audioPlayer play];
```

## ZQPlayer结构

![ZQPlayer结构](https://upload-images.jianshu.io/upload_images/2268074-988275caa655bf9f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

ZQPlayerImage.bundle 为图片资源，若是需要自定义控件图标课进行相应的替换；
ZQPlayer 为基于AVPlayer封装的播放器，可以播放网络和本地的视频音频；
ZQPlayerMaskView 为播放视图UI，是在ZQPlayer上加了一层各种控件，如播放、当前时间、进度条、总时间、全屏等，相应的滑动快进快退手势等，还有加载动画等；
提示：ZQPlayerMaskView 依赖于Masonry进行布局

## ZQPlayer 

### ZQPlayer.h方法和属性

```
@interface ZQPlayer : NSObject

/** 使用播放源进行初始化 */
- (instancetype)initWithUrl:(NSString *)url;
/** 下一首 */
- (void)nextWithUrl:(NSString *)url;
/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;

// 是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;

/** 视频音频长度 */
@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic, weak) id<ZQPlayerDelegate> delegate;

// 播放器
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItme;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end
```

### 播放器的状态

```
typedef NS_ENUM(NSUInteger, ZQPlayerState) {
    ZQPlayerStateReadyToPlay, // 播放器准备完毕
    ZQPlayerStatePlaying, // 正在播放（用户播放）
    ZQPlayerStatePause, // 暂停 （用户暂停）
    ZQPlayerStateStop, // 播放完毕
    ZQPlayerStateBufferEmpty, // 缓冲中（这个状态会暂停视频，进行缓冲）
    ZQPlayerStateKeepUp // 缓冲完成（这个状态可以播放）
};
```

### 代理

```
@protocol ZQPlayerDelegate <NSObject>
@optional
/**
 播放器状态变化
 @param player 播放器
 @param state 状态
 */
- (void)ZQPlayerStateChange:(ZQPlayer *)player state:(ZQPlayerState)state;
/**
 视频源开始加载后调用 ，返回视频的长度
 @param player 播放器
 @param time 长度（秒）
 */
- (void)ZQPlayerTotalTime:(ZQPlayer *)player totalTime:(CGFloat)time;
/**
 视频源加载时调用 ，返回视频的缓冲长度
 @param player 播放器
 @param time 长度（秒）
 */
- (void)ZQPlayerLoadTime:(ZQPlayer *)player loadTime:(CGFloat)time;
/**
 播放时调用，返回当前时间
 @param player 播放器
 @param time 播放到当前的时间（秒）
 */
- (void)ZQPlayerCurrentTime:(ZQPlayer *)player currentTime:(CGFloat)time;
@end
```

## ZQPlayerMaskView 

ZQPlayerMaskView.h

```
@interface ZQPlayerMaskView : UIView

@property (nonatomic, weak) id <ZQPlayerDelegate> delegate;
/** 播放器 */
@property (nonatomic, strong,readonly) ZQPlayer *player;
/** 背景图片 
使用 backgroundImage.image来进行设置*/
@property (nonatomic, strong,readonly) UIImageView *backgroundImage;

/**
 是否为Wi-Fi环境 (默认为YES)
 若为YES则会自动播放视频，如果NO，则会弹出提示框给用户进行选择
 建议获取用户网络环境，若是移动环境则设置为NO，其他设置为YES
 */
@property (nonatomic, assign) BOOL isWiFi;

/** 用播放源进行播放 */
- (void)playWithVideoUrl:(NSString *)videoUrl;
@end
```

若需要自定义播放UI，可以参考ZQPlayerMaskView进行自定义


