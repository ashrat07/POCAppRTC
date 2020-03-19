//
//  WebViewController.m
//  POCAppRTC
//
//  Created by Ashish Rathore on 13/03/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewController.h"

@interface WebViewController () <WKUIDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation WebViewController

@synthesize webView;

//void WKPreferencesSetMediaDevicesEnabled(WKPreferences* preferencesRef, bool enabled);

- (void)viewDidLoad
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [[WKPreferences alloc] init];
    configuration.preferences = preferences;
//    WKPreferencesSetMediaDevicesEnabled(preferences, YES);

//    [preferences setValue:@(YES) forKey:@"MediaDevicesEnabled"];
//    [preferences setValue:@(YES) forKeyPath:@"MediaDevicesEnabled"];

    webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;

    [self.view addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [webView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [webView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;

    NSString *urlString = @"https://webrtc.github.io/samples/src/content/getusermedia/gum/";
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
}

@end
