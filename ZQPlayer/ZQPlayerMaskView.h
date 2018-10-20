//
//  ZQPlayerMaskView.h
//  ZQPlayer
//
//  Created by wang on 2018/3/16.
//  Copyright © 2018年 qigge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZQPlayer.h"

@interface ZQPlayerMaskView : UIView

@property (nonatomic, weak) id <ZQPlayerDelegate> delegate;
/** 播放器 */
@property (nonatomic, strong) ZQPlayer *player;
/** 背景图片 */
@property (nonatomic, strong) UIImageView *backgroundImage;

// 控件
/** 顶部包含，返回按钮，标题等视图 */
@property (nonatomic, strong) UIView *topView;
/** 标题 */
@property (nonatomic, strong) UILabel *titleLab;
/** 全屏后的返回按钮 */
@property (nonatomic, strong) UIButton *backBtn;
/** 底部包含，播放、当前时间、总时间、进度条等视图 */
@property (nonatomic, strong) UIView *bottomView;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton *fullBtn;
/** 播放按钮 */
@property (nonatomic, strong) UIButton *playBtn;
/** 当前时间 */
@property (nonatomic, strong) UILabel *currentTimeLabel;
/** 总时间 */
@property (nonatomic, strong) UILabel *totalTimeLabel;
/** 加载进度条 */
@property (nonatomic, strong) UIProgressView *progressView;
/** 视频播放进度条 */
@property (nonatomic, strong) UISlider *videoSlider;

/**
 是否为Wi-Fi环境 (默认为YES)
 若为YES则会自动播放视频，如果NO，则会弹出提示框给用户进行选择
 建议获取用户网络环境，若是移动环境则设置为NO，其他设置为YES
 */
@property (nonatomic, assign) BOOL isWiFi;

/** 用播放源进行播放 */
- (void)playWithVideoUrl:(NSString *)videoUrl;

/** 全屏 和退出全屏 */
- (void)videoFullAction;


@end
