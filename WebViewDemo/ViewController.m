//
//  ViewController.m
//  WebViewDemo
//
//  Created by Object on 2021/3/3.
//  Copyright © 2021 lsp. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "GRHWKURLSchemeHandler.h"
@interface ViewController ()

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSString *jScript = @"window.webkit.messageHandlers.event.postMessage({\"\":\"\"});";
    WKUserScript *js = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaTypesRequiringUserActionForPlayback = NO;
    [configuration.userContentController addUserScript:js];
    [configuration setURLSchemeHandler:[[GRHWKURLSchemeHandler alloc] init] forURLScheme:@"herald-hybrid"];
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.wkWebView.backgroundColor = [UIColor yellowColor];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://app.paintstrain.com/ybjx/?url=https://m.v.qq.com/x/play.html?cid=mzc00200oxq32bf"]];
    [self.wkWebView loadRequest:req];
    [self.view addSubview:self.wkWebView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveDataNoti:) name:@"DidReceiveDataNSNotificationName" object:nil];
}

- (void)didReciveDataNoti:(NSNotification *)notification{
    
    NSDictionary *notiDic = notification.userInfo;
    NSLog(@"拦截到的信息：%@",notiDic);
}

@end
