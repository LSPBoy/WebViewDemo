//
//  CustomURLManager.h
//  WebViewDemo
//
//  Created by Object on 2021/3/3.
//  Copyright © 2021 lsp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomURLManager : NSObject

@property (nonatomic,assign) BOOL isSwizzle;

+ (CustomURLManager *)shareManager;

- (void)wk_registerScheme:(NSString *)scheme;
- (void)wk_unregisterScheme:(NSString *)scheme;

@end

NS_ASSUME_NONNULL_END
