//
//  CustomURLManager.m
//  WebViewDemo
//
//  Created by Object on 2021/3/3.
//  Copyright © 2021 lsp. All rights reserved.
//

#import "CustomURLManager.h"
#import <objc/runtime.h>
#import "CustomURLProtocol.h"
#import <WebKit/WebKit.h>
@implementation CustomURLManager

+ (CustomURLManager *)shareManager{
    static CustomURLManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CustomURLManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.isSwizzle = NO;
    }
    return self;
}

- (Class)ContextControllerClass{
    static Class cls;
    if (!cls) {
//        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
       cls = NSClassFromString(@"WKBrowsingContextController");
    }
    return cls;
}

- (void)wk_registerScheme:(NSString *)scheme {
    self.isSwizzle = YES;
    Class cls = [self ContextControllerClass];
    SEL sel =  NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
//        [(id)cls performSelector:sel withObject:scheme];
        [(id)cls performSelector:sel withObject:@"https" withObject:@"http"];
    }
}

- (void)wk_unregisterScheme:(NSString *)scheme {
    self.isSwizzle=NO;
    Class cls = [self ContextControllerClass];
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
        [(id)cls performSelector:sel withObject:scheme];
    }
}



@end
