//
//  AboutViewController.m
//  KonaBot-Mac
//
//  Created by Alex Ling on 28/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak) IBOutlet WebView *webView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_webView.policyDelegate = self;
	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
	[[_webView mainFrame] loadHTMLString:html baseURL:nil];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
	NSString *host = request.URL.host;
	if (host) {
		[[NSWorkspace sharedWorkspace] openURL:request.URL];
	} else {
		[listener use];
	}
}

@end
