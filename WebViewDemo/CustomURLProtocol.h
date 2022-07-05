//
//  CustomURLProtocol.h
//  WebViewDemo
//
//  Created by Object on 2021/3/3.
//  Copyright © 2021 lsp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomURLProtocol : NSURLProtocol

+ (void)startMonitor;

+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
