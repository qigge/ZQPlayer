//
//  MCAVPlayerItemCacheLoader.h
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>

@interface MCAVPlayerItemCacheLoader : NSObject<AVAssetResourceLoaderDelegate>

@property (nonatomic,readonly) NSString *cacheFilePath;

+ (instancetype)cacheLoaderWithCacheFilePath:(NSString *)cacheFilePath;
- (instancetype)initWithCacheFilePath:(NSString *)cacheFilePath;
+ (void)removeCacheWithCacheFilePath:(NSString *)cacheFilePath;
@end
