//
//  CustomURLProtocol.m
//  WebViewDemo
//
//  Created by Object on 2021/3/3.
//  Copyright © 2021 lsp. All rights reserved.
//

#import "CustomURLProtocol.h"
#import "CustomURLManager.h"

static NSString *const kProtocolHandledKey = @"kProtocolHandledKey";

@interface CustomURLProtocol()<NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;

@end


@implementation CustomURLProtocol

+ (void)startMonitor {
    CustomURLManager *manager = [CustomURLManager shareManager];
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    if (![manager isSwizzle]) {
        [manager wk_registerScheme:@"http"];
        [manager wk_registerScheme:@"https"];
    }
}

+ (void)stopMonitor {
    CustomURLManager *manager = [CustomURLManager shareManager];
    [NSURLProtocol unregisterClass:[CustomURLProtocol class]];
    if ([manager isSwizzle]) {
         [manager wk_unregisterScheme:@"http"];
         [manager wk_unregisterScheme:@"https"];
    }
}




+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"]  == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:kProtocolHandledKey inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];

//    [NSURLProtocol setProperty:@(YES)
//                        forKey:kProtocolHandledKey
//                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {

//    NSURLSessionConfiguration *configuration =
//    [NSURLSessionConfiguration defaultSessionConfiguration];
//
//    self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
//    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
//    self.sessionDelegateQueue.name = @"com.xx.queue";
//
//    NSURLSession *session =
//    [NSURLSession sessionWithConfiguration:configuration
//                                  delegate:self
//                             delegateQueue:self.sessionDelegateQueue];
//
//    self.dataTask = [session dataTaskWithRequest:self.request];
//    [self.dataTask resume];
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kProtocolHandledKey inRequest:mutableReqeust];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.dataTask = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
    
}


- (void)stopLoading {
    [self.dataTask cancel];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
   
    [self.client URLProtocol:self didLoadData:data];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"=============%@*******%@",dataDict,dataStr);
//    if (dataDict || dataStr) {
//        NSMutableDictionary *notiDic = [NSMutableDictionary dictionary];
//        notiDic[@"url"] = self.response.URL.absoluteString;
//        notiDic[@"dataDic"] = dataDict;
//        notiDic[@"dataStr"] = dataStr;
//       [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveDataNSNotificationName" object:nil userInfo:notiDic];
//    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.response = response;
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}


@end
