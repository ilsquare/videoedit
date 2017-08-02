//
//  VideoEditTool.h
//  videoeditlib
//
//  Created by Seth on 2017/7/24.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^editCompleteBlock)(NSMutableArray <UIImage *>*, float currentTime);
typedef void (^cropCompleteBlock)(BOOL);

@interface VideoEditTool : NSObject

// 每3秒读取一帧视频
- (void)extractFrames:(NSString *)filePath complete:(editCompleteBlock)complteBlock;

// 视频裁剪
-(void)cropVideo:(NSString *)filePath outPath:(NSString *)outpath WithStartSecond:(Float64)startSecond andcropSecond:(Float64)cropSecond complete:(cropCompleteBlock)complete;

@end
