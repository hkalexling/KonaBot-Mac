//
//  PreferenceViewController.m
//  KonaBot-Mac
//
//  Created by Alex Ling on 27/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import "PreferenceViewController.h"

@interface PreferenceViewController ()

@property (weak) IBOutlet NSPopUpButton *scoreButton;
@property (weak) IBOutlet NSButton *autoUpdateButton;
@property (weak) IBOutlet NSPopUpButton *updateIntervalButton;
@property (weak) IBOutlet NSTextField *intervalLabel;

@end

@implementation PreferenceViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *scoreStr = [NSString stringWithFormat:@"%@", @([Utility minimumScore])];
	[_scoreButton selectItemWithTitle:scoreStr];
	
	BOOL autoUpdate = [Utility autoUpdate];
	_autoUpdateButton.state = autoUpdate ? NSOnState : NSOffState;
	_updateIntervalButton.enabled = autoUpdate;
	_intervalLabel.textColor = autoUpdate ? [NSColor blackColor] : [NSColor lightGrayColor];
	
	NSInteger updateInterval = [Utility updateInterval];
	[_updateIntervalButton selectItemWithTitle:[Utility stringFromSeconds:updateInterval]];
}

- (IBAction)minimumScoreUpdated:(NSPopUpButton *)sender {
	NSString *title = sender.selectedItem.title;
	[Utility setMinimumScore:[title integerValue]];
}

- (IBAction)autoUpdateToggled:(NSButton *)sender {
	BOOL state = sender.state == NSOnState;
	_updateIntervalButton.enabled = state;
	_intervalLabel.textColor = state ? [NSColor blackColor] : [NSColor lightGrayColor];
	[Utility setAutoUpdate:state];
}

- (IBAction)updateIntervalChanged:(NSPopUpButton *)sender {
	NSString *title = sender.selectedItem.title;
	[Utility setUpdateInterval:[Utility secondsFromString:title]];
}

@end
