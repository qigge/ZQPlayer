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
@property (nonatomic, strong,readonly) ZQPlayer *player;
/** 背景图片 */
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
