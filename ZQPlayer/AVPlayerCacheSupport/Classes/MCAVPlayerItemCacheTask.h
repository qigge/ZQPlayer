//
//  MCAVPlayerItemCacheTask.h
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCAVPlayerItemCacheTask;
typedef void (^MCAVPlayerItemCacheTaskFinishedBlock)(MCAVPlayerItemCacheTask *task,NSError *error);

@class MCAVPlayerItemCacheFile;
@class AVAssetResourceLoadingRequest;
@interface MCAVPlayerItemCacheTask : NSOperation
{
@protected
    AVAssetResourceLoadingRequest *_loadingRequest;
    NSRange _range;
    MCAVPlayerItemCacheFile *_cacheFile;
}

@property (nonatomic,copy) MCAVPlayerItemCacheTaskFinishedBlock finishBlock;

- (instancetype)initWithCacheFile:(MCAVPlayerItemCacheFile *)cacheFile loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range;
@end
