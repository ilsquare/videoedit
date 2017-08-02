//
//  ViewController.m
//  videoedit
//
//  Created by Seth on 2017/7/24.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "ViewController.h"
#import "VideoEditTool.h"
#import "VideoEditView.h"
#import "Masonry.h"

#define PlayUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()
@property (nonatomic, strong) VideoEditView *scorllerView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *cropBtn;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_4116" ofType:@"MP4"];
    self.filePath = filePath;
    [self initUI];
}

- (void)initUI{
    VideoEditTool *editTool = [[VideoEditTool alloc] init];
    __weak typeof(self) weak = self;
    [editTool extractFrames:self.filePath complete:^(NSMutableArray *imageArr,float currentTime) {
        __strong typeof(weak) self = weak;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refrshData:imageArr currentTime:currentTime];
            
        });
    }];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [self.view addSubview:cancelBtn];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(ClickBackBut) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.bottom.equalTo(@0);
        make.height.equalTo(@43);
    }];
    
    UIButton *cropBtn = [[UIButton alloc] init];
    [self.view addSubview:cropBtn];
    cropBtn.backgroundColor = [UIColor clearColor];
    [cropBtn setTitle:@"确定" forState:UIControlStateNormal];
    [cropBtn setTitleColor:PlayUIColorFromRGB(0xFFC500) forState:UIControlStateNormal];
    cropBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cropBtn addTarget:self action:@selector(cropVideo) forControlEvents:UIControlEventTouchUpInside];
    self.cropBtn = cropBtn;
    [cropBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.bottom.equalTo(@0);
        make.height.equalTo(@43);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [self.view addSubview:timeLabel];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"0.0s";
    self.timeLabel = timeLabel;
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(54));
        make.bottom.equalTo(@-95);
    }];
}
- (void)ClickBackBut{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 裁剪视频
- (void)cropVideo{
    VideoEditTool *editTool = [[VideoEditTool alloc] init];
    [editTool cropVideo:self.filePath outPath:nil WithStartSecond:self.scorllerView.startSecond andcropSecond:self.scorllerView.cropSecond complete:^(BOOL success) {
        if (success) {
            NSLog(@"视频裁剪成功");
        }else{
            NSLog(@"视频裁剪失败");
        }
        
    }];
}


#pragma mark - 每3秒读取视频一帧，并显示
- (void)refrshData:(NSMutableArray *)imageArr currentTime:(float)time{
    VideoEditView *scorllerView = [[VideoEditView alloc] initWithImageArr:imageArr duration:time frame:CGRectMake(0, self.view.frame.size.height - 50 - 45, self.view.frame.size.width, 50)];
    [self.view addSubview:scorllerView];
    self.scorllerView = scorllerView;
    
    __weak typeof(self) weak = self;
    scorllerView.switchValueBlock = ^(float startSecond, float endSecond) {
        __strong typeof(weak) self = weak;
        self.timeLabel.text = [NSString stringWithFormat:@"%.1fs",startSecond];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
