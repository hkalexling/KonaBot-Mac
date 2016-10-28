//
//  Utility.m
//  KonaBot-Mac
//
//  Created by Alex Ling on 27/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import "Utility.h"


@implementation Utility

+ (BOOL)r18 {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"r18"];
}

+ (void)setR18: (BOOL) r18 {
	[[NSUserDefaults standardUserDefaults] setBool:r18 forKey:@"r18"];
}

+ (NSInteger)minimumScore {
	NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"minimumScore"];
	if (num){
		return [num integerValue];
	}
	return 100;
}

+ (void)setMinimumScore:(NSInteger)score {
	[[NSUserDefaults standardUserDefaults] setObject:@(score) forKey:@"minimumScore"];
}

+ (BOOL) autoUpdate {
	id update = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoUpdate"];
	if (update){
		return [update boolValue];
	}
	return YES;
}

+ (void) setAutoUpdate:(BOOL)update {
	[[NSUserDefaults standardUserDefaults] setObject:@(update) forKey:@"autoUpdate"];
}

+ (CGFloat) updateInterval {
	NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateInterval"];
	if (interval){
		return [interval floatValue];
	}
	return 3600.0f;
}

+ (void) setUpdateInterval:(CGFloat)interval {
	[[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:@"updateInterval"];
}

+ (NSInteger) secondsFromString:(NSString *)string {
	NSString *numStr = [string componentsSeparatedByString:@" "][0];
	NSString *unit = [string componentsSeparatedByString:@" "][1];
	
	NSInteger num = [numStr integerValue];
	
	NSInteger unitInterval = 1;
	if ([unit isEqualToString:@"min"]){
		unitInterval = 60;
	}
	else if ([unit isEqualToString:@"hr"]){
		unitInterval = 3600;
	}
	else if ([unit isEqualToString:@"day"]){
		unitInterval = 3600 * 24;
	}
	
	NSInteger seconds = unitInterval * num;
	return seconds;
}

+ (NSString *) stringFromSeconds:(NSInteger)seconds {
	NSInteger dayNum = seconds / (24 * 3600);
	NSInteger hourNum = seconds % (24 * 3600) / 3600;
	NSInteger minNum = seconds % (24 * 3600) % 3600 / 60;
		
	if (dayNum > 0 && hourNum == 0 && minNum == 0){
		return [NSString stringWithFormat:@"%@ %@", @(dayNum), @"day"];
	}
	else if (dayNum == 0 && hourNum > 0 && minNum == 0){
		return [NSString stringWithFormat:@"%@ %@", @(hourNum), @"hr"];
	}
	else if (dayNum == 0 && hourNum == 0 && minNum > 0){
		return [NSString stringWithFormat:@"%@ %@", @(minNum), @"min"];
	}
	
	return nil;
}

+ (NSString *) fullStringFromSeconds:(NSInteger)seconds {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDate *date = [NSDate dateWithTimeInterval:seconds sinceDate:[NSDate new]];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate new] toDate:date options:0];
	
	NSString *str = @"";
	if (components.day > 0){
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ day ", @(components.day)]];
	}
	if (components.hour > 0){
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ hr ", @(components.hour)]];
	}
	if (components.minute > 0){
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ min ", @(components.minute)]];
	}
	if (components.second > 0){
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ sec ", @(components.second)]];
	}
	return str;
}

+ (NSDate *) lastUpdateDate {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateDate"];
}

+ (void) setLastUpdateDate:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastUpdateDate"];
}

+ (NSString *) supportPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *support = [[paths firstObject] stringByAppendingPathComponent:@"com.hkalexling.konabot"];
	return support;
}

+ (RACSignal *) clearSupportDirectory {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSFileManager *manager = [NSFileManager defaultManager];
			NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:[Utility supportPath]];
			NSError *error;
			
			NSString *file;
			while (file = [enumerator nextObject]) {
				if ([[file pathExtension] isEqualToString:@"jpg"]) {
					[manager removeItemAtPath:[[Utility supportPath] stringByAppendingPathComponent:file] error:&error];
				}
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error){
					[subscriber sendError:error];
				}
				else{
					[subscriber sendCompleted];
				}
			});
		});
		
		return nil;
	}];
}

+ (RACSignal *)imageFromURL:(NSString *)url {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
		manager.responseSerializer = [AFImageResponseSerializer serializer];
		[manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			NSImage *image = (NSImage *)responseObject;
			if (!image){
				NSError *error = [NSError errorWithDomain:@"com.hkalexling.konamanager" code:200 userInfo:@{@"error": @"reponse is not an image"}];
				[subscriber sendError:error];
			}
			else{
				[subscriber sendNext:image];
				[subscriber sendCompleted];
			}
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[subscriber sendError:error];
		}];
		return nil;
	}];
}

+ (RACSignal *)jsonFromURL:(NSString *)url parameters:(NSDictionary *)parameters {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
		[manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
		manager.responseSerializer = [AFJSONResponseSerializer serializer];
		
		[manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			if (responseObject){
				[subscriber sendNext:responseObject];
				[subscriber sendCompleted];
			}
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[subscriber sendError:error];
		}];
		return nil;
	}];
}

+ (RACSignal *)saveImageToSupport:(NSImage *)image {
	return [[Utility clearSupportDirectory] then:^RACSignal * _Nonnull{
		return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
			NSFileManager *manager = [NSFileManager defaultManager];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				BOOL isDir;
				if (![manager fileExistsAtPath:[Utility supportPath] isDirectory:&isDir]){
					NSError *error;
					[manager createDirectoryAtPath:[Utility supportPath] withIntermediateDirectories:YES attributes:nil error:&error];
					if (error){
						dispatch_async(dispatch_get_main_queue(), ^{
							[subscriber sendError:error];
						});
					}
				}
				
				NSString *name = [NSString stringWithFormat:@"%@.jpg", @([[NSDate date] timeIntervalSince1970])];
				NSString *imgPath = [[Utility supportPath] stringByAppendingPathComponent:name];
				
				NSData *imageData = [image TIFFRepresentation];
				NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
				NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
				imageData = [rep representationUsingType:NSJPEGFileType properties:imageProps];
				[imageData writeToFile:imgPath atomically:YES];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[subscriber sendNext:imgPath];
					[subscriber sendCompleted];
				});
			});
			
			return nil;
		}];
	}];
}

+ (RACSignal *) setWallpaper: (NSString *) path; {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		NSURL *url = [NSURL fileURLWithPath:path];
		NSArray *screens = [NSScreen screens];
		for (NSScreen *screen in screens){
			NSError *error;
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:screen options:@{} error:&error];
			if (error){
				[subscriber sendError: error];
			}
			else{
				[subscriber sendCompleted];
			}
		}
		return nil;
	}];
}

@end
