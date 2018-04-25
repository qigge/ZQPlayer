//
//  MCCacheSupportUtils.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCCacheSupportUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

static NSString *const kAVPlayerItemMCCacheSupportUrlSchemeSuffix = @"-stream";
NSString *const MCCacheSubDirectoryName = @"AVPlayerMCCache";
const NSRange MCInvalidRange = {NSNotFound,0};

@implementation NSString (MCCacheSupport)
- (NSString *)mc_md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)mc_isM3U
{
    return [[[self pathExtension] lowercaseString] hasPrefix:@"m3u"];
}
@end

@implementation NSURL (MCCacheSupport)
- (NSURL *)mc_URLByReplacingSchemeWithString:(NSString *)scheme
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    components.scheme = scheme;
    return components.URL;
}

- (NSURL *)mc_avplayerCacheSupportURL
{
    if (![self mc_isAvPlayerCacheSupportURL])
    {
        NSString *scheme = [[self scheme] stringByAppendingString:kAVPlayerItemMCCacheSupportUrlSchemeSuffix];
        return [self mc_URLByReplacingSchemeWithString:scheme];
    }
    return self;
}

- (NSURL *)mc_avplayerOriginalURL
{
    if ([self mc_isAvPlayerCacheSupportURL])
    {
        NSString *scheme = [[self scheme] stringByReplacingOccurrencesOfString:kAVPlayerItemMCCacheSupportUrlSchemeSuffix withString:@""];
        return [self mc_URLByReplacingSchemeWithString:scheme];
    }
    return self;
}

- (BOOL)mc_isAvPlayerCacheSupportURL
{
    return [[self scheme] hasSuffix:kAVPlayerItemMCCacheSupportUrlSchemeSuffix];
}

- (NSString *)mc_pathComponentRelativeToURL:(NSURL *)baseURL
{
    NSString *absoluteString = [self absoluteString];
    NSString *baseURLString = [baseURL absoluteString];
    NSRange range = [absoluteString rangeOfString:baseURLString];
    if (range.location == 0)
    {
        NSString *subString = [absoluteString substringFromIndex:range.location + range.length];
        return subString;
    }
    return nil;
}

- (BOOL)mc_isM3U
{
    return [[[self pathExtension] lowercaseString] hasPrefix:@"m3u"];
}
@end

@implementation NSURLRequest (MCCacheSupport)
- (NSRange)mc_range
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    NSString *rangeString = [self allHTTPHeaderFields][@"Range"];
    if ([rangeString hasPrefix:@"bytes="])
    {
        NSArray* components = [[rangeString substringFromIndex:6] componentsSeparatedByString:@","];
        if (components.count == 1)
        {
            components = [[components firstObject] componentsSeparatedByString:@"-"];
            if (components.count == 2)
            {
                NSString* startString = [components objectAtIndex:0];
                NSInteger startValue = [startString integerValue];
                NSString* endString = [components objectAtIndex:1];
                NSInteger endValue = [endString integerValue];
                if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue))
                {  // The second 500 bytes: "500-999"
                    range.location = startValue;
                    range.length = endValue - startValue + 1;
                }
                else if (startString.length && (startValue >= 0))
                {  // The bytes after 9500 bytes: "9500-"
                    range.location = startValue;
                    range.length = NSUIntegerMax;
                }
                else if (endString.length && (endValue > 0))
                {  // The final 500 bytes: "-500"
                    range.location = NSNotFound;
                    range.length = endValue;
                }
            }
        }
    }
    return range;
}
@end

@implementation NSHTTPURLResponse (MCCacheSupport)
- (long long)mc_fileLength
{
    NSString *range = [self allHeaderFields][@"Content-Range"];
    if (range)
    {
        NSArray *ranges = [range componentsSeparatedByString:@"/"];
        if (ranges.count > 0)
        {
            NSString *lengthString = [[ranges lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            return [lengthString longLongValue];
        }
    }
    else
    {
        return [self expectedContentLength];
    }
    return 0;
}

- (BOOL)mc_supportRange
{
    return [self allHeaderFields][@"Content-Range"] != nil;
}
@end

@implementation AVAssetResourceLoadingRequest (MCCacheSupport)
- (void)mc_fillContentInformation:(NSHTTPURLResponse *)response
{
    if (!response)
    {
        return;
    }
    
    self.response = response;
    
    if (!self.contentInformationRequest)
    {
        return;
    }
    
    NSString *mimeType = [response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    self.contentInformationRequest.byteRangeAccessSupported = [response mc_supportRange];
    self.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    self.contentInformationRequest.contentLength = [response mc_fileLength];
}
@end

@implementation NSFileHandle (MCCacheSupport)
- (BOOL)mc_safeWriteData:(NSData *)data
{
    NSInteger retry = 3;
    size_t bytesLeft = data.length;
    const void *bytes = [data bytes];
    int fileDescriptor = [self fileDescriptor];
    while (bytesLeft > 0 && retry > 0)
    {
        ssize_t amountSent = write(fileDescriptor, bytes + data.length - bytesLeft, bytesLeft);
        if (amountSent < 0)
        {
            //write failed
            break;
        }
        else
        {
            bytesLeft = bytesLeft - amountSent;
            if (bytesLeft > 0)
            {
                //not finished continue write after sleep 1 second
                sleep(1);  //probably too long, but this is quite rare
                retry--;
            }
        }
    }
    return bytesLeft == 0;
}
@end
