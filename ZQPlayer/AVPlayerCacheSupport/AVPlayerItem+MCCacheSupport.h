//
//  AVPlayerItem+MCCacheSupport.h
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

AVF_EXPORT NSString *const AVPlayerMCCacheErrorDomain NS_AVAILABLE(10_9, 7_0);

typedef NS_ENUM(NSUInteger, AVPlayerMCCacheError)
{
    AVPlayerMCCacheErrorFileURL = -1111900,
    AVPlayerMCCacheErrorSchemeNotHTTP = -1111901,
    AVPlayerMCCacheErrorUnsupportFormat = -1111902,
    AVPlayerMCCacheErrorCreateCacheFileFailed = -1111903,
};

@interface AVPlayerItem (MCCacheSupport)

/**
 *  get original url, do not use [(AVURLAsset *)self.asset URL].
 */
@property (nonatomic,copy,readonly) NSURL *mc_URL;

/**
 *  cache file path.
 */
@property (nonatomic,copy,readonly) NSString *mc_cacheFilePath NS_AVAILABLE(10_9, 7_0);

/**
 *  AVPlayerItem with cache support, same to -mc_playerItemWithRemoteURL:URL options:nil error:error
 *
 *  @param URL     original request url
 *
 *  @return AVPlayerItem with cache support
 */
+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL error:(NSError **)error NS_AVAILABLE(10_9, 7_0);

/**
 *  AVPlayerItem with cache support, same to -mc_playerItemWithRemoteURL:URL options:options cacheFilePath:nil error:error
 *
 *  @param URL     original request url
 *  @param options An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey
 *
 *  @return AVPlayerItem with cache support
 */
+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL options:(NSDictionary<NSString *, id> *)options error:(NSError **)error NS_AVAILABLE(10_9, 7_0);

/**
 *  create AVPlayerItem with cache support
 *
 *  @param URL           original request url
 *  @param options       An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey
 *
 *  @param cacheFilePath cache file path, if cacheFilePath is nil the cache will be put in NSTemporaryDirectory()/AVPlayerMCCache
 *  @param error         nil means success, otherwise failed, input url will not be cached
 *
 *  @return AVPlayerItem with cache support
 */
+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL options:(NSDictionary<NSString *, id> *)options cacheFilePath:(NSString *)cacheFilePath error:(NSError **)error NS_AVAILABLE(10_9, 7_0);

/**
 *  remove cache file and cache index file
 *
 *  @param cacheFilePath cache file path.
 */
+ (void)mc_removeCacheWithCacheFilePath:(NSString *)cacheFilePath NS_AVAILABLE(10_9, 7_0);
@end
