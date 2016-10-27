//
//  KonaManager.m
//  KonaBot-Mac
//
//  Created by Alex Ling on 26/10/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

#import "KonaManager.h"

@implementation KonaPost

// [{"id":179749,"tags":"animal_ears ao_no_exorcist bandage black_hair blonde_hair blue_eyes blush cake candy catboy catgirl chain collar dualscreen food glasses gloves green_eyes group halloween hat headband headdress kamiki_izumo lollipop miwa_konekomaru miyama-uguisu_monaka moriyama_shiemi navel okumura_rin okumura_yukio pink_hair pumpkin purple_hair red_eyes shima_renzou short_hair suguro_ryuji tail torn_clothes wink witch_hat yellow_eyes yoru_(ao_no_exorcist) yuuno_(yukioka)","created_at":1395889296,"creator_id":78648,"author":"STORM","change":1065760,"source":"http://www.pixiv.net/member_illust.php?mode=medium\u0026illust_id=22658116","score":78,"md5":"2ed2e475df56d84dc7a8927dc611b5bc","file_size":1046077,"file_url":"http://konachan.com/image/2ed2e475df56d84dc7a8927dc611b5bc/Konachan.com%20-%20179749%20bandage%20blush%20cake%20candy%20catboy%20catgirl%20chain%20collar%20food%20glasses%20gloves%20group%20hat%20headband%20lollipop%20navel%20pink_hair%20pumpkin%20red_eyes%20tail%20wink.jpg","is_shown_in_index":true,"preview_url":"http://konachan.com/data/preview/2e/d2/2ed2e475df56d84dc7a8927dc611b5bc.jpg","preview_width":150,"preview_height":51,"actual_preview_width":300,"actual_preview_height":102,"sample_url":"http://konachan.com/sample/2ed2e475df56d84dc7a8927dc611b5bc/Konachan.com%20-%20179749%20sample.jpg","sample_width":1500,"sample_height":509,"sample_file_size":713820,"jpeg_url":"http://konachan.com/image/2ed2e475df56d84dc7a8927dc611b5bc/Konachan.com%20-%20179749%20bandage%20blush%20cake%20candy%20catboy%20catgirl%20chain%20collar%20food%20glasses%20gloves%20group%20hat%20headband%20lollipop%20navel%20pink_hair%20pumpkin%20red_eyes%20tail%20wink.jpg","jpeg_width":2450,"jpeg_height":832,"jpeg_file_size":0,"rating":"s","has_children":false,"parent_id":null,"status":"active","width":2450,"height":832,"is_held":false,"frames_pending_string":"","frames_pending":[],"frames_string":"","frames":[]}]

+ (void)createFromJson: (NSDictionary *) json handler: (void (^)(KonaPost *, NSError *)) handler {
	KonaPost *post = [KonaPost new];
	post.postID = [[json objectForKey:@"id"] integerValue];
	NSString *tags = [json objectForKey:@"tags"];
	NSMutableArray *tagAry = [NSMutableArray new];
	for (NSString *tag in [tags componentsSeparatedByString:@" "]) {
		NSString *tag_ = [tag stringByReplacingOccurrencesOfString:@"_" withString:@" "];
		[tagAry addObject:tag_];
	}
	post.tags = tagAry;
	post.createAt = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"created_at"] integerValue]];
	post.score = [[json objectForKey:@"score"] integerValue];
	post.previewURL = [json objectForKey:@"preview_url"];
	post.previewSize = CGSizeMake([[json objectForKey:@"preview_width"] floatValue], [[json objectForKey:@"preview_height"] floatValue]);
	post.URL = [json objectForKey:@"jpeg_url"];
	post.size = CGSizeMake([[json objectForKey:@"jpeg_width"] floatValue], [[json objectForKey:@"jpeg_height"] floatValue]);
	post.rating = [json objectForKey:@"rating"];
	
	[[Utility imageFromURL:post.URL] subscribeNext:^(NSImage *img) {
		post.image = img;
		handler(post, nil);
	} error:^(NSError *error) {
		handler(nil, error);
	}];	
}

@end

@implementation KonaManager

- (RACSignal *)getRandomPost {
	NSLog(@"getting");
	NSString *url = @"http://konachan.com/post.json";
	NSDictionary *parameters = @{@"tags": @"order:random", @"limit": @(1)};
	return [[Utility jsonFromURL:url parameters:parameters] flattenMap:^RACStream *(NSArray *jsons) {
		
		if ([[jsons[0] objectForKey:@"score"] integerValue] < [Utility minimumScore] || ([Utility r18] ? false : ![[jsons[0] objectForKey:@"rating"] isEqualToString:@"s"])){
			return [self getRandomPost];
		}
		
		return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
			[KonaPost createFromJson:jsons[0] handler:^(KonaPost *post, NSError *error) {
				if (error){
					[subscriber sendError: error];
				}
				else{
					[subscriber sendNext:post];
					[subscriber sendCompleted];
				}
			}];
			return nil;
		}];
	}];
}

@end
