//
//  MCCacheSupportUtils.h
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>

FOUNDATION_EXTERN const NSRange MCInvalidRange;
FOUNDATION_EXTERN NSString *const MCCacheSubDirectoryName;

NS_INLINE BOOL MCValidByteRange(NSRange range)
{
    return ((range.location != NSNotFound) || (range.length > 0));
}

NS_INLINE BOOL MCValidFileRange(NSRange range)
{
    return ((range.location != NSNotFound) && range.length > 0 && range.length != NSUIntegerMax);
}

NS_INLINE BOOL MCRangeCanMerge(NSRange range1,NSRange range2)
{
    return (NSMaxRange(range1) == range2.location) || (NSMaxRange(range2) == range1.location) || NSIntersectionRange(range1, range2).length > 0;
}

NS_INLINE NSString* MCRangeToHTTPRangeHeader(NSRange range)
{
    if (MCValidByteRange(range))
    {
        if (range.location == NSNotFound)
        {
            return [NSString stringWithFormat:@"bytes=-%tu",range.length];
        }
        else if (range.length == NSUIntegerMax)
        {
            return [NSString stringWithFormat:@"bytes=%tu-",range.location];
        }
        else
        {
            return [NSString stringWithFormat:@"bytes=%tu-%tu",range.location, NSMaxRange(range) - 1];
        }
    }
    else
    {
        return nil;
    }
}

NS_INLINE NSString* MCRangeToHTTPRangeReponseHeader(NSRange range,NSUInteger length)
{
    if (MCValidByteRange(range))
    {
        NSUInteger start = range.location;
        NSUInteger end = NSMaxRange(range) - 1;
        if (range.location == NSNotFound)
        {
            start = range.location;
        }
        else if (range.length == NSUIntegerMax)
        {
            start = length - range.length;
            end = start + range.length - 1;
        }
        return [NSString stringWithFormat:@"bytes %tu-%tu/%tu",start,end,length];
    }
    else
    {
        return nil;
    }
}

NS_INLINE NSString *MCCacheTemporaryDirectory()
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:MCCacheSubDirectoryName];
}

NS_INLINE NSString *MCCacheDocumentyDirectory()
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (directories.count > 0)
    {
        return [[directories firstObject] stringByAppendingPathComponent:MCCacheSubDirectoryName];
    }
    return nil;
}

@interface NSString (MCCacheSupport)
- (NSString *)mc_md5;
- (BOOL)mc_isM3U;
@end

@interface NSURL (MCCacheSupport)
- (NSURL *)mc_URLByReplacingSchemeWithString:(NSString *)scheme;
- (NSURL *)mc_avplayerCacheSupportURL;
- (NSURL *)mc_avplayerOriginalURL;
- (BOOL)mc_isAvPlayerCacheSupportURL;
- (NSString *)mc_pathComponentRelativeToURL:(NSURL *)baseURL;
- (BOOL)mc_isM3U;
@end

@interface NSURLRequest (MCCacheSupport)
@property (nonatomic,readonly) NSRange mc_range;
@end

@interface NSHTTPURLResponse (MCCacheSupport)
- (long long)mc_fileLength;
- (BOOL)mc_supportRange;
@end

@interface AVAssetResourceLoadingRequest (MCCacheSupport)
- (void)mc_fillContentInformation:(NSHTTPURLResponse *)response;
@end

@interface NSFileHandle (MCCacheSupport)
- (BOOL)mc_safeWriteData:(NSData *)data;
@end
