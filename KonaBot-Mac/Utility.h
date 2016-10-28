//
//  Utility.h
//  KonaBot-Mac
//
//  Created by Alex Ling on 27/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface Utility : NSObject

+ (NSString *) supportPath;
+ (RACSignal *) clearSupportDirectory;

+ (BOOL) r18;
+ (void) setR18: (BOOL) r18;

+ (NSInteger) minimumScore;
+ (void) setMinimumScore: (NSInteger) score;

+ (CGFloat) updateInterval;
+ (void) setUpdateInterval: (CGFloat) interval;

+ (BOOL) autoUpdate;
+ (void) setAutoUpdate: (BOOL) update;

+ (NSString *) wallpaperPath;
+ (void) setWallpaperPath: (NSString *) path;

+ (NSDate *) lastUpdateDate;
+ (void) setLastUpdateDate: (NSDate *) date;

+ (NSInteger) secondsFromString: (NSString *) string;
+ (NSString *) stringFromSeconds: (NSInteger) seconds;
+ (NSString *) fullStringFromSeconds: (NSInteger) seconds;

+ (RACSignal *)imageFromURL: (NSString *) url;
+ (RACSignal *)jsonFromURL: (NSString *) url parameters: (NSDictionary *) parameters;
+ (RACSignal *) saveImageToSupport: (NSImage *) image;
+ (RACSignal *) setWallpaper: (NSString *) path;

@end
