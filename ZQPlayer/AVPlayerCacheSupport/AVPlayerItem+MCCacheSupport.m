//
//  AVPlayerItem+MCCacheSupport.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "AVPlayerItem+MCCacheSupport.h"
#import "MCAVPlayerItemCacheLoader.h"
#import "MCCacheSupportUtils.h"
#import <objc/runtime.h>

NSString *const AVPlayerMCCacheErrorDomain = @"AVPlayerMCCacheErrorDomain";
static const void * const kAVPlayerItemMCCacheSupportCacheLoaderKey = &kAVPlayerItemMCCacheSupportCacheLoaderKey;

@implementation AVPlayerItem (MCCacheSupport)

#pragma mark - init
+ (NSError *)mc_errorWithCode:(AVPlayerMCCacheError)errorCode reason:(NSString *)reason
{
    return [NSError errorWithDomain:AVPlayerMCCacheErrorDomain code:errorCode userInfo:@{
                                                                                         NSLocalizedDescriptionKey : @"The operation couldn’t be completed.",
                                                                                         NSLocalizedFailureReasonErrorKey : reason,
                                                                                         }];
}

+ (NSError *)mc_checkURL:(NSURL *)URL
{
    AVPlayerMCCacheError errorCode = 0;
    NSString *reason = nil;
    if ([URL isFileURL])
    {
        errorCode = AVPlayerMCCacheErrorFileURL;
        reason = @"can not cache file URL.";
    }
    else if (![[[URL scheme] lowercaseString] hasPrefix:@"http"])
    {
        errorCode = AVPlayerMCCacheErrorSchemeNotHTTP;
        reason = @"only support URL with http scheme.";
    }
    else if ([URL mc_isM3U])
    {
        errorCode = AVPlayerMCCacheErrorUnsupportFormat;
        reason = @"do not support playlist format.";
    }
    
    if (errorCode == 0)
    {
        return nil;
    }
    else
    {
        return [self mc_errorWithCode:errorCode reason:reason];
    }
}

+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL error:(NSError *__autoreleasing *)error
{
    return [self mc_playerItemWithRemoteURL:URL options:nil cacheFilePath:nil error:error];
}

+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options error:(NSError *__autoreleasing *)error
{
    return [self mc_playerItemWithRemoteURL:URL options:options cacheFilePath:nil error:error];
}

+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options cacheFilePath:(NSString *)cacheFilePath error:(NSError *__autoreleasing *)error
{
    NSError *err = [self mc_checkURL:URL];
    if (err)
    {
        if (error != NULL)
        {
            *error = err;
        }
        return [self playerItemWithURL:URL];
    }
    
    NSString *path = cacheFilePath;
    if (!path)
    {
        path = [[MCCacheTemporaryDirectory() stringByAppendingPathComponent:[[URL absoluteString] mc_md5]] stringByAppendingPathExtension:[URL pathExtension]];
    }
    
    MCAVPlayerItemCacheLoader *cacheLoader = [MCAVPlayerItemCacheLoader cacheLoaderWithCacheFilePath:path];
    if (!cacheLoader)
    {
        if (*error)
        {
            *error = [self mc_errorWithCode:AVPlayerMCCacheErrorCreateCacheFileFailed reason:@"create cache file failed."];
        }
        return [self playerItemWithURL:URL];
    }
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[URL mc_avplayerCacheSupportURL] options:options];
    [asset.resourceLoader setDelegate:cacheLoader queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [self playerItemWithAsset:asset];
    objc_setAssociatedObject(item, kAVPlayerItemMCCacheSupportCacheLoaderKey, cacheLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return item;
}

+ (void)mc_removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [MCAVPlayerItemCacheLoader removeCacheWithCacheFilePath:cacheFilePath];
}

#pragma mark - property
- (MCAVPlayerItemCacheLoader *)mc_cacheLoader
{
    return objc_getAssociatedObject(self, kAVPlayerItemMCCacheSupportCacheLoaderKey);
}

- (NSURL *)mc_URL
{
    if (![self.asset isKindOfClass:[AVURLAsset class]])
    {
        return nil;
    }
    AVURLAsset *asset = (AVURLAsset *)self.asset;
    return [asset.URL mc_avplayerOriginalURL];
}

- (NSString *)mc_cacheFilePath
{
    return [self mc_cacheLoader].cacheFilePath;
}
@end
