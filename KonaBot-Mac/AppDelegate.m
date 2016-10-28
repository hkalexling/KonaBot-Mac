//
//  AppDelegate.m
//  KonaBot-Mac
//
//  Created by Alex Ling on 26/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate{
	NSStatusItem *item;
	NSMenuItem *nextItem;
	NSMenuItem *r18Item;
	KonaManager *manager;
	NSWindowController *preferenceWC;
	BOOL getting;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	item.button.image = [NSImage imageNamed:@"statusBarIconTemplate"];
	
	NSMenu *menu = [NSMenu new];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Update" action:@selector(update) keyEquivalent:@""]];
	nextItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
	[menu addItem:nextItem];
	[menu addItem:[NSMenuItem separatorItem]];
	r18Item = [[NSMenuItem alloc] initWithTitle: [Utility r18] ? @"Disable R18" : @"Enable R18" action:@selector(toggleR18) keyEquivalent:@""];
	[menu addItem:r18Item];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Preference" action:@selector(preference) keyEquivalent:@","]];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@"q"]];
	
	item.menu = menu;
	
	manager = [KonaManager new];
	[self updateNextUpdateTime];
	
	[NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
	
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
}

- (void)toggleR18 {
	[Utility setR18:![Utility r18]];
	r18Item.title = [Utility r18] ? @"Disable R18" : @"Enable R18";
}

- (void)update {
	[self setNextUpdateTime:@"--"];
	[self updateWallpaper];
}

- (void)preference {
	preferenceWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"preferenceWindowController"];
	[preferenceWC showWindow:self];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)quit {
	exit(0);
}

- (void)updateWallpaper {
	getting = YES;
	[[[[manager getRandomPost] flattenMap:^RACStream *(KonaPost *post) {
		NSLog(@"score: %@", @(post.score));
		return [Utility saveImageToSupport:post.image];
	}] flattenMap:^RACStream *(NSString *path) {
		return [Utility setWallpaper:path];
	}] subscribeError:^(NSError * _Nullable error) {
		NSLog(@"failed with error: %@", error);
		getting = NO;
	} completed:^{
		NSLog(@"succeed");
		[Utility setLastUpdateDate:[NSDate date]];
		getting = NO;
	}];
}

- (void)setNextUpdateTime: (NSString *) string {
	nextItem.title = [NSString stringWithFormat:@"Next Update: %@", string];
}

- (void)updateNextUpdateTime {
	if ([Utility autoUpdate]){
		NSDate *lastDate = [Utility lastUpdateDate];
		if (lastDate){
			CGFloat interval =[[NSDate date] timeIntervalSinceDate:lastDate];
			CGFloat diff = [Utility updateInterval] - interval;
			if (diff < 0) diff = 0.0f;
			NSString *timeStr = [Utility fullStringFromSeconds:diff];
			[self setNextUpdateTime:[NSString stringWithFormat:@"%@", timeStr]];
			return;
		}
	}
	[self setNextUpdateTime:@"--"];
}

- (void)checkTime {
	if (getting){
		return;
	}
	[self updateNextUpdateTime];
	if ([Utility autoUpdate]){
		NSDate *lastDate = [Utility lastUpdateDate];
		if (lastDate){
			CGFloat interval = [[NSDate date] timeIntervalSinceDate:lastDate];
			if (interval > [Utility updateInterval]){
				[self updateWallpaper];
			}
		}
	}
}

@end
