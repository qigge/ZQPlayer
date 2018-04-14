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

@property (nonatomic, strong) ZQPlayerMaskView *playerMaskView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _playerMaskView = [[ZQPlayerMaskView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width*0.56)];
    _playerMaskView.delegate = self;
    _playerMaskView.isWiFi = YES; // 是否允许自动加载，
    [self.view addSubview:_playerMaskView];
    
    NSString *videoUrl = @"http://183.60.197.29/17/q/t/v/w/qtvwspkejwgqjqeywjfowzdjcjvjzs/hc.yinyuetai.com/A0780162B98038FBED45554E85720E53.mp4?sc=e9bad1bb86f52b6f&br=781&vid=3192743&aid=38959&area=KR&vst=2&ptp=mv&rd=yinyuetai.com";
    [_playerMaskView playWithVideoUrl:videoUrl]; 
    
    [_playerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(100);
        make.height.equalTo(_playerMaskView.mas_width).multipliedBy(0.56);
    }];
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
// 全屏需要重写方法 用来将播放器
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator  {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait || orientation
        == UIDeviceOrientationPortraitUpsideDown) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [_playerMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(100);;
            make.height.equalTo(_playerMaskView.mas_width).multipliedBy(0.56);
        }];
    }else {
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
