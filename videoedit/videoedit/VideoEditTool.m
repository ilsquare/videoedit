//
//  VideoEditTool.m
//  videoeditlib
//
//  Created by Seth on 2017/7/24.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "VideoEditTool.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

// 文件夹部分
#define downloadBasePath ({\
NSString *sandboxPath=NSHomeDirectory();\
NSString *basePath=[sandboxPath stringByAppendingString:@"/Documents"];\
[[NSFileManager defaultManager] createDirectoryAtPath:[basePath stringByAppendingString:@"/DTDownLoad/DTThumb"] withIntermediateDirectories:YES attributes:nil error:nil];\
[[NSFileManager defaultManager] createDirectoryAtPath:[basePath stringByAppendingString:@"/DTDownLoad/DTParanoma"] withIntermediateDirectories:YES attributes:nil error:nil];\
basePath;\
})

#define DTParanomaPath [downloadBasePath stringByAppendingString:@"/DTDownLoad/DTParanoma"]

@interface VideoEditTool (){
    CGFloat originViedoWidth;//原视频图像的宽
    CGFloat originViedoHeight;//原视频图像的高

}

@end

@implementation VideoEditTool

// 每3秒读取一帧视频
- (void)extractFrames:(NSString *)filePath complete:(editCompleteBlock)complteBlock{
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
    //setting up generator & compositor
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.maximumSize = CGSizeMake(200, 100);

    generator.appliesPreferredTrackTransform = YES;
    AVVideoComposition *composition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:asset];

    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    
    NSMutableArray *times = [[NSMutableArray alloc] init];
    NSMutableArray *imageArry = [[NSMutableArray alloc] init];
    NSLog(@"duration:%f",duration);
    NSTimeInterval frameDuration = CMTimeGetSeconds(composition.frameDuration);
    CGFloat totalFrames = round(duration/frameDuration);
    float fps = [[asset tracksWithMediaType:AVMediaTypeVideo].lastObject nominalFrameRate];// 视频帧率

    for (int i = 0; i < (int)totalFrames; i += 3 * fps) {
        NSLog(@"%d,%d",(int)totalFrames,i);
        NSValue *time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration, composition.frameDuration.timescale)];
        [times addObject:time];
    }

    //  3秒拿一张图片
    __block NSInteger count = 0;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        count++;
        if(CMTimeCompare(actualTime, requestedTime) == 0){
            if (result == AVAssetImageGeneratorSucceeded) {
                //直接把该图片读出来
                UIImage *img = [UIImage imageWithCGImage:im];
                img = [self thumbnailWithImageWithoutScale:img size:CGSizeMake(500, 250)];
                img = [self cutTranscodingImage:img];
                [imageArry addObject:img];
            }else if(result == AVAssetImageGeneratorFailed){
            }else if(result == AVAssetImageGeneratorCancelled){
            }
        }else{
            NSLog(@"error");
        }
        NSLog(@"count%li",(long)count);
        if (count == times.count) {
            if (complteBlock) {
                complteBlock(imageArry,duration);
            }
        }
    };
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
    
}

//图片压缩
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image){
        newimage = nil;
    }else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height){
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

//裁剪转码图片
- (UIImage *)cutTranscodingImage:(UIImage*)image{
    int width = image.size.width;
    int height = image.size.height;
    
    CGImageRef orginImageRef = [image CGImage];
    CGImageRef imageRef = nil;
    imageRef = CGImageCreateWithImageInRect(orginImageRef, CGRectMake((width-height)/2.0, 0, height, height));
    UIImage *orginImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return orginImage;
    
}

// 视频裁剪
-(void)cropVideo:(NSString *)filePath outPath:(NSString *)outpath WithStartSecond:(Float64)startSecond andcropSecond:(Float64)cropSecond complete:(cropCompleteBlock)complete{
    NSLog(@"开始裁剪%f,裁剪时长%f",startSecond,cropSecond);
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    float fps = [[asset tracksWithMediaType:AVMediaTypeVideo].lastObject nominalFrameRate];

    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    startSecond = [NSString stringWithFormat:@"%.1f",startSecond].doubleValue;
    cropSecond = [NSString stringWithFormat:@"%.1f",cropSecond].doubleValue;
    CMTime start = CMTimeMakeWithSeconds(startSecond, fps); // 帧率需要获取当前视频实时帧率
    CMTime duration = CMTimeMakeWithSeconds(cropSecond, fps);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:
//                 [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                 NSLog(@"Export Complete %ld %@", (long)exportSession.status, exportSession.error);
                 if (complete) {
                     complete(YES);
                 }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 if (complete) {
                     complete(NO);
                 }
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 if (complete) {
                     complete(NO);
                 }
                 break;
             default:
                 break;
         }
     }];
}


@end
