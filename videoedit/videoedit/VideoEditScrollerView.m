//
//  VideoEditScrollerView.m
//  videoedit
//
//  Created by lsq on 2017/7/25.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "VideoEditScrollerView.h"

@interface VideoEditScrollerView ()
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, assign) float videoTime;
@end

@implementation VideoEditScrollerView

- (void)dealloc{
    NSLog(@"VideoEditScrollerView dealloc");
}

- (instancetype)initWithImageArr:(NSMutableArray *)imageArr duration:(float)time frame:(CGRect)frame{
    if (self == [super init]) {
        _imageArr = imageArr;
        self.frame = frame;
        _videoTime = time;
        [self initUI];
    }
    return self;

}

- (void)initUI{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator  = NO;
    // 根据实际计算长度
    float totalWidth = self.videoTime * ([UIScreen mainScreen].bounds.size.width - 124) / 30;
    
    // 加载图片
    float width = totalWidth / (self.imageArr.count * 1.0);
    for (int i = 0; i < self.imageArr.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [self.imageArr objectAtIndex:i];
        imageView.frame = CGRectMake(62 + width*i, 0, width, self.frame.size.height);
        [self addSubview:imageView];
    }
    self.contentSize = CGSizeMake(width * self.imageArr.count + 62 * 2, self.frame.size.height);
    
}


@end

