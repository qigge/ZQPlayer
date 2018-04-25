//
//  MCAVPlayerItemCacheTask.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemCacheTask.h"

@interface MCAVPlayerItemCacheTask ()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation MCAVPlayerItemCacheTask
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithCacheFile:(MCAVPlayerItemCacheFile *)cacheFile loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range
{
    self = [super init];
    if (self)
    {
        _loadingRequest = loadingRequest;
        _range = range;
        _cacheFile = cacheFile;
    }
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        [self setFinished:NO];
        [self setExecuting:YES];
        if (_finishBlock)
        {
            _finishBlock(self,nil);
        }
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
@end
