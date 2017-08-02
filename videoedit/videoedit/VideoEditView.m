//
//  VideoEditView.m
//  videoedit
//
//  Created by lsq on 2017/7/25.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "VideoEditView.h"
#import "VideoEditScrollerView.h"
#import "Masonry.h"

@interface VideoEditView ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) UILabel *upSelectLabel;
@property (nonatomic, strong) UILabel *downSelectLabel;
@property (nonatomic, strong) UILabel *scrollerSelectLabel;
@property (nonatomic, strong) UIImageView *leftSliderView;
@property (nonatomic, strong) UIImageView *rightSliderView;
@property (nonatomic, strong) VideoEditScrollerView *scrollerView;
@property (nonatomic, assign) float videoTime;
@property (nonatomic, assign) float scrollerTime;
@property (nonatomic, assign) float currentPoint;
@property (nonatomic, strong) UIView *progressBarView;  ///< 进度播放view
@property (nonatomic, strong) UIView *selectView;       // 选中框

@end

@implementation VideoEditView

- (void)dealloc{
    NSLog(@"VideoEditView dealloc");
}

- (instancetype)initWithImageArr:(NSMutableArray <UIImage *>*)imageArr duration:(float)time frame:(CGRect)frame{
    if (self == [super init]) {
        _imageArr = imageArr;
        _startSecond = 0;
        _cropSecond = 30;
        _videoTime = time;
        _currentPoint = 0;
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        [self initUI];
    }
    return self;
}

- (UILabel *)upSelectLabel{
    if (!_upSelectLabel) {
        _upSelectLabel = [[UILabel alloc] init];
    }
    return _upSelectLabel;
}

- (UILabel *)downSelectLabel{
    if (!_downSelectLabel) {
        _downSelectLabel = [[UILabel alloc] init];
    }
    return _downSelectLabel;
}

- (UILabel *)scrollerSelectLabel{
    if (!_scrollerSelectLabel) {
        _scrollerSelectLabel = [[UILabel alloc] init];
    }
    return _scrollerSelectLabel;
}

- (UIImageView *)leftSliderView{
    if (!_leftSliderView) {
        _leftSliderView = [[UIImageView alloc] init];
    }
    return _leftSliderView;
}


- (UIImageView *)rightSliderView{
    if (!_rightSliderView) {
        _rightSliderView = [[UIImageView alloc] init];
    }
    return _rightSliderView;
}

- (void)initUI{
    VideoEditScrollerView *scrollerView = [[VideoEditScrollerView alloc] initWithImageArr:_imageArr duration:self.videoTime frame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:scrollerView];
    scrollerView.delegate = self;
    scrollerView.bounces = YES;
    self.userInteractionEnabled = YES;
    scrollerView.scrollEnabled = YES;
    scrollerView.userInteractionEnabled = YES;
    self.scrollerView = scrollerView;
    
    
    UIView *selectView= [[UIView alloc] init];
    [self addSubview:selectView];
    self.selectView = selectView;
    selectView.backgroundColor = [UIColor clearColor];
    selectView.userInteractionEnabled = NO;
    selectView.layer.masksToBounds = YES;
    selectView.layer.cornerRadius = 5;
    selectView.layer.borderColor = [UIColor whiteColor].CGColor;
    selectView.layer.borderWidth = 2;
    [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@62);
        make.right.equalTo(@-62);
        make.bottom.equalTo(@2);
        make.height.equalTo(@54);
    }];
    
    // 蒙层
    UIView *leftLayerView = [[UIView alloc] init];
    [self addSubview:leftLayerView];
    [leftLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@50);
        make.width.equalTo(@62);
    }];
    leftLayerView.userInteractionEnabled = NO;
    leftLayerView.backgroundColor = [UIColor blackColor];
    leftLayerView.alpha = 0.6;

    UIView *rightLayerView = [[UIView alloc] init];
    [self addSubview:rightLayerView];
    [rightLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@50);
        make.width.equalTo(@62);
    }];
    rightLayerView.userInteractionEnabled = NO;
    rightLayerView.backgroundColor = [UIColor blackColor];
    rightLayerView.alpha = 0.6;

    // 加载选择框
//    self.upSelectLabel.frame = CGRectMake(width, 0, self.frame.size.width - width * 2, 3);
//    [self addSubview:self.upSelectLabel];
//    self.upSelectLabel.backgroundColor = [UIColor whiteColor];
//    self.upSelectLabel.userInteractionEnabled = YES;
//    
//    self.downSelectLabel.frame = CGRectMake(width, self.frame.size.height - 3, self.frame.size.width - width * 2, 3);
//    [self addSubview:self.downSelectLabel];
//    self.downSelectLabel.backgroundColor = [UIColor whiteColor];
//    self.downSelectLabel.userInteractionEnabled = YES;
//
//    
//    self.leftSliderView.backgroundColor = [UIColor whiteColor];
//    self.leftSliderView.frame = CGRectMake(width, 0, 8, self.frame.size.height);
//    [self addSubview:self.leftSliderView];
//    self.leftSliderView.userInteractionEnabled = YES;
//
//    self.rightSliderView.backgroundColor = [UIColor whiteColor];
//    self.rightSliderView.frame = CGRectMake(self.frame.size.width - width - 8 , 0, 8, self.frame.size.height);
//    [self addSubview:self.rightSliderView];
//    self.rightSliderView.userInteractionEnabled = YES;

    self.scrollerTime = scrollerView.contentSize.width;
    NSLog(@"%f",scrollerView.contentSize.width);
    
//    UIView *progressBarView = [UIView new];
//    progressBarView.hidden = NO;
//    progressBarView.backgroundColor = [UIColor whiteColor];
//    [self addSubview:progressBarView];
//    self.progressBarView = progressBarView;
//    progressBarView.frame = CGRectMake(width + 8, 3, 4, self.frame.size.height - 6);
    
}


#pragma mark - Private
- (void)fillForeGroundViewWithPoint:(CGPoint)point touchView:(UIView *)touchView{
    if (touchView == self.leftSliderView) {
        float currentWidth = self.rightSliderView.frame.origin.x;
        float width = self.frame.size.width / 12.0;
        float tipWith = currentWidth - point.x;
        float pointx = point.x;
        if (currentWidth - point.x <= width) {
            tipWith = width + 8;
            pointx = currentWidth - width ;
        }else if (point.x <= width){
            pointx = width;
            tipWith = currentWidth - pointx;
        }
        self.leftSliderView.frame = CGRectMake(pointx, 0, 8, self.frame.size.height);
        self.upSelectLabel.frame = CGRectMake(pointx, 0, tipWith, 3);
        self.downSelectLabel.frame = CGRectMake(pointx, self.frame.size.height - 3, tipWith, 3);
    }else if (touchView == self.rightSliderView){
        float currentWidth = self.leftSliderView.frame.origin.x;
        float width = self.frame.size.width / 12.0;
        float tipWith = point.x - currentWidth;
        float pointx = point.x - 8;
        if (tipWith <= width) {
            pointx = currentWidth + width ;
            tipWith = width;
        }else if (point.x >= width * 12){
            pointx = width * 12 ;
            tipWith = pointx - currentWidth;
        }
        self.rightSliderView.frame = CGRectMake(pointx, 0, 8, self.frame.size.height);
        self.upSelectLabel.frame = CGRectMake(currentWidth, 0, tipWith, 3);
        self.downSelectLabel.frame = CGRectMake(currentWidth, self.frame.size.height - 3, tipWith, 3);
    }
    self.progressBarView.hidden = YES;
    [self timeSwitch];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //[self fillForeGroundViewWithPoint:point touchView:touch.view];

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"%f",point.x);
    [self fillForeGroundViewWithPoint:point touchView:touch.view];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (touch.view != self.leftSliderView) {
        return;
    }
    
}

#pragma mark - scorllerViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSLog(@"scrollViewDidEndDragging");
    if (decelerate) {
        NSLog(@"decelerate");
    }else{
        NSLog(@"no decelerate");
        
    }
    [self timeSwitch];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self timeSwitch];
}

- (void)timeSwitch{
    CGPoint point = self.scrollerView.contentOffset;
    float width = 62;
    // 截取初始位置
    float orgin = self.selectView.frame.origin.x - width;
    // 截取开始
    float starts = point.x + orgin;
    NSLog(@"orgin:%f point:%f starts:%f",orgin,point.x,starts);

    // 截取长度
    float croDuration = ([UIScreen mainScreen].bounds.size.width - 124);
    // 视频换算单位
    float switchDuration = 30 / ([UIScreen mainScreen].bounds.size.width - 124);

    // 截取的视频长度
    float videoDuration = croDuration * switchDuration;
    // 开始时间
    float videStart =  starts * switchDuration;
    
    self.cropSecond = videoDuration;
    self.startSecond = videStart;
    
    // 超过距离才播放
    //if (point.x - self.currentPoint > SpacePoint) {
    if (self.switchValueBlock) {
        if (self.startSecond < 0) {
            self.startSecond = 0;
        }
        if (self.startSecond > self.videoTime - 30) {
            self.startSecond = self.videoTime - 30;
        }
        self.switchValueBlock(self.startSecond,self.cropSecond + self.startSecond);
    }
    //}
    // float
    NSLog(@"%f,%f, %f,%f",point.x,self.leftSliderView.frame.origin.x - width,videoDuration,self.cropSecond);
//    NSLog(@"开始时间%f",self.videoTime / self.scrollerTime * starts);
}

- (void)setProgress:(float)value{
    if (value < 0) {
        value = 0;
    }
    float position = self.leftSliderView.frame.origin.x +  ( self.frame.size.width / (30.0 / 11.0 * 12) * value);
    if (position > self.rightSliderView.frame.origin.x) {
        position = self.rightSliderView.frame.origin.x;
    }
    NSLog(@"value: %f",value);
    NSLog(@"position : %f", position);
    self.progressBarView.hidden = NO;
    self.progressBarView.frame = CGRectMake(position + 8, 3, 3, self.frame.size.height - 6);
}

@end
