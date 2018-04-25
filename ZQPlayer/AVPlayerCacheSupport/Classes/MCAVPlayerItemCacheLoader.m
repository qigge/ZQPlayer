//
//  MCAVPlayerItemCacheLoader.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemCacheLoader.h"
#import "MCAVPlayerItemLocalCacheTask.h"
#import "MCAVPlayerItemRemoteCacheTask.h"
#import "MCCacheSupportUtils.h"
#import "MCAVPlayerItemCacheFile.h"

@interface MCAVPlayerItemCacheLoader ()<NSURLConnectionDataDelegate>
{
@private
    NSMutableArray<AVAssetResourceLoadingRequest *> *_pendingRequests;
    AVAssetResourceLoadingRequest *_currentRequest;
    NSRange _currentDataRange;
    MCAVPlayerItemCacheFile *_cacheFile;
    NSHTTPURLResponse *_response;
}
@property (nonatomic,strong) NSOperationQueue *operationQueue;
@end

@implementation MCAVPlayerItemCacheLoader

#pragma mark - init & dealloc
+ (instancetype)cacheLoaderWithCacheFilePath:(NSString *)cacheFilePath
{
    return [[self alloc] initWithCacheFilePath:cacheFilePath];
}

- (instancetype)initWithCacheFilePath:(NSString *)cacheFilePath
{
    self = [super init];
    if (self)
    {
        _cacheFile = [MCAVPlayerItemCacheFile cacheFileWithFilePath:cacheFilePath];
        if (!_cacheFile)
        {
            return nil;
        }
        _pendingRequests = [[NSMutableArray alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.name = @"com.avplayeritem.mccache";
        _currentDataRange = MCInvalidRange;
    }
    return self;
}

- (NSString *)cacheFilePath
{
    return _cacheFile.cacheFilePath;
}

+ (void)removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[cacheFilePath stringByAppendingString:[MCAVPlayerItemCacheFile indexFileExtension]] error:NULL];
}

- (void)dealloc
{
    [_operationQueue cancelAllOperations];
}

#pragma mark - loading request
- (void)startNextRequest
{
    if (_currentRequest || _pendingRequests.count == 0)
    {
        return;
    }
    
    _currentRequest = [_pendingRequests firstObject];
    
    //data range
    if ([_currentRequest.dataRequest respondsToSelector:@selector(requestsAllDataToEndOfResource)] && _currentRequest.dataRequest.requestsAllDataToEndOfResource)
    {
        _currentDataRange = NSMakeRange((NSUInteger)_currentRequest.dataRequest.requestedOffset, NSUIntegerMax);
    }
    else
    {
        _currentDataRange = NSMakeRange((NSUInteger)_currentRequest.dataRequest.requestedOffset, _currentRequest.dataRequest.requestedLength);
    }
    
    //response
    if (!_response && _cacheFile.responseHeaders.count > 0)
    {
        if (_currentDataRange.length == NSUIntegerMax)
        {
            _currentDataRange.length = [_cacheFile fileLength] - _currentDataRange.location;
        }
        
        NSMutableDictionary *responseHeaders = [_cacheFile.responseHeaders mutableCopy];
        NSString *contentRangeKey = @"Content-Range";
        BOOL supportRange = responseHeaders[contentRangeKey] != nil;
        if (supportRange && MCValidByteRange(_currentDataRange))
        {
            responseHeaders[contentRangeKey] = MCRangeToHTTPRangeReponseHeader(_currentDataRange, [_cacheFile fileLength]);
        }
        else
        {
            [responseHeaders removeObjectForKey:contentRangeKey];
        }
        responseHeaders[@"Content-Length"] = [NSString stringWithFormat:@"%tu",_currentDataRange.length];

        NSInteger statusCode = supportRange ? 206 : 200;
        _response = [[NSHTTPURLResponse alloc] initWithURL:_currentRequest.request.URL statusCode:statusCode HTTPVersion:@"HTTP/1.1" headerFields:responseHeaders];
        [_currentRequest mc_fillContentInformation:_response];
    }
    [self startCurrentRequest];
}

- (void)startCurrentRequest
{
    _operationQueue.suspended = YES;
    if (_currentDataRange.length == NSUIntegerMax)
    {
        [self addTaskWithRange:NSMakeRange(_currentDataRange.location, NSUIntegerMax) cached:NO];
    }
    else
    {
        NSUInteger start = _currentDataRange.location;
        NSUInteger end = NSMaxRange(_currentDataRange);
        while (start < end)
        {
            NSRange firstNotCachedRange = [_cacheFile firstNotCachedRangeFromPosition:start];
            if (!MCValidFileRange(firstNotCachedRange))
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:_cacheFile.cachedDataBound > 0];
                start = end;
            }
            else if (firstNotCachedRange.location >= end)
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:YES];
                start = end;
            }
            else if (firstNotCachedRange.location >= start)
            {
                if (firstNotCachedRange.location > start)
                {
                    [self addTaskWithRange:NSMakeRange(start, firstNotCachedRange.location - start) cached:YES];
                }
                NSUInteger notCachedEnd = MIN(NSMaxRange(firstNotCachedRange), end);
                [self addTaskWithRange:NSMakeRange(firstNotCachedRange.location, notCachedEnd - firstNotCachedRange.location) cached:NO];
                start = notCachedEnd;
            }
            else
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:YES];
                start = end;
            }
        }
    }
    _operationQueue.suspended = NO;
}

- (void)cancelCurrentRequest:(BOOL)finishCurrentRequest
{
    [_operationQueue cancelAllOperations];
    if (finishCurrentRequest)
    {
        if (!_currentRequest.isFinished)
        {
            [self currentRequestFinished:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
        }
    }
    else
    {
        [self cleanUpCurrentRequest];
    }
}

- (void)currentRequestFinished:(NSError *)error
{
    if (error)
    {
        [_currentRequest finishLoadingWithError:error];
    }
    else
    {
        [_currentRequest finishLoading];
    }
    [self cleanUpCurrentRequest];
    [self startNextRequest];
}

- (void)cleanUpCurrentRequest
{
    [_pendingRequests removeObject:_currentRequest];
    _currentRequest = nil;
    _response = nil;
    _currentDataRange = MCInvalidRange;
}

- (void)addTaskWithRange:(NSRange)range cached:(BOOL)cached
{
    MCAVPlayerItemCacheTask *task = nil;
    if (cached)
    {
        task = [[MCAVPlayerItemLocalCacheTask alloc] initWithCacheFile:_cacheFile loadingRequest:_currentRequest range:range];
    }
    else
    {
        task = [[MCAVPlayerItemRemoteCacheTask alloc] initWithCacheFile:_cacheFile loadingRequest:_currentRequest range:range];
        [(MCAVPlayerItemRemoteCacheTask *)task setResponse:_response];
    }
    __weak typeof(self)weakSelf = self;
    task.finishBlock = ^(MCAVPlayerItemCacheTask *task, NSError *error)
    {
        if (task.cancelled || error.code == NSURLErrorCancelled)
        {
            return;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error)
        {
            [strongSelf currentRequestFinished:error];
        }
        else
        {
            if (strongSelf.operationQueue.operationCount == 1)
            {
                [strongSelf currentRequestFinished:nil];
            }
        }
    };
    [_operationQueue addOperation:task];
}

#pragma mark - resource loader delegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self cancelCurrentRequest:YES];
    [_pendingRequests addObject:loadingRequest];
    [self startNextRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    if (_currentRequest == loadingRequest)
    {
        [self cancelCurrentRequest:NO];
    }
    else
    {
        [_pendingRequests removeObject:loadingRequest];
    }
}
@end
