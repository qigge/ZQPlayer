//
//  ViewController.m
//  ZQVideoPlayer
//
//  Created by wang on 2018/4/13.
//  Copyright © 2018年 wang. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ZQPlayerMaskView.h"


@interface ViewController ()<ZQPlayerDelegate>

/** 视频播放器*/
@property (nonatomic, strong) ZQPlayerMaskView *playerMaskView;


/** 音频播放器 */
@property (nonatomic, strong) ZQPlayer *audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 视频播放
    _playerMaskView = [[ZQPlayerMaskView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width*0.56)];
    _playerMaskView.delegate = self;
    _playerMaskView.isWiFi = YES; // 是否允许自动加载，
    [self.view addSubview:_playerMaskView];
    
    // 网络视频
    NSString *videoUrl = @"http://220.170.49.104/13/h/g/h/u/hghumdhsmfhebwbhqbkluuxijccqdg/hc.yinyuetai.com/07350162CEBBD913D20F2F340BEE6084.mp4?sc=16011da08ddd8dc9&br=784&vid=3195269&aid=37&area=HT&vst=0&ptp=mv&rd=yinyuetai.com";
    // 本地视频
    // NSString *videoUrl = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    [_playerMaskView playWithVideoUrl:videoUrl];
    
    [_playerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(100);
        make.height.equalTo(_playerMaskView.mas_width).multipliedBy(0.56);
    }];
    
    // 音频播放
//    NSString *mp3Url = @"http://m10.music.126.net/20180414124141/e3e56fbce547d0fabda73f65db249437/ymusic/1f36/af3d/60a8/f7ac35fcd56465570b2031b93edd2546.mp3";
//    _audioPlayer = [[ZQPlayer alloc] initWithUrl:mp3Url];
//    [_audioPlayer play];
}



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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
