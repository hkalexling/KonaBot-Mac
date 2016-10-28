//
//  KonaManager.h
//  KonaBot-Mac
//
//  Created by Alex Ling on 26/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "Utility.h"
#import "AppDelegate.h"

@interface KonaPost : NSObject

@property NSInteger postID;
@property NSArray<NSString *> *tags;
@property NSDate *createAt;
@property NSInteger score;
@property NSString *previewURL;
@property CGSize previewSize;
@property NSString *URL;
@property CGSize size;
@property NSString *rating;
@property NSImage *image;

+ (void)createFromJson: (NSDictionary *) json handler: (void (^)(KonaPost *post, NSError *error)) handler;

@end

@interface KonaManager : NSObject

- (RACSignal *)getRandomPost;

@end
