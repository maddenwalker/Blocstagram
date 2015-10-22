//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/8/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", "Back Command")

@interface LoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIBarButtonItem *backButton;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString *) redirectURI {
    return @"http://linkinprofile.com";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.title = NSLocalizedString(@"Login", @"Login");
    
    //add navigation bar button item
    [self addNavigationButton];
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    
}

- (void)viewWillLayoutSubviews {
    self.webView.frame = self.view.bounds;
}

-(void)dealloc {
    [self clearInstagramCookies];
    
    self.webView.delegate = nil;
}

#pragma mark UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenString = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenString];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        
        return NO;
    }
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.canGoBack) {
        [self updateButton:YES];
    } else {
        [self updateButton:NO];
    }
}


#pragma helper methods

-(void)clearInstagramCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

-(void) addNavigationButton {
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:kWebBrowserBackString style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemPressed:)];
    self.backButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = self.backButton;
}

- (void) backBarButtonItemPressed:(UIButton *)button {
    [self.webView goBack];
}

- (void) updateButton:(BOOL)enabled {
    self.backButton.enabled = enabled;
}

@end
