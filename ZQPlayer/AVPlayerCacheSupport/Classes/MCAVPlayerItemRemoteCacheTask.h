//
//  MCAVPlayerItemRemoteCacheTask.h
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemCacheTask.h"

@interface MCAVPlayerItemRemoteCacheTask : MCAVPlayerItemCacheTask

@property (nonatomic,strong) NSHTTPURLResponse *response;

@end
