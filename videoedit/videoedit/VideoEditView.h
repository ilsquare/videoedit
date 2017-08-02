//
//  VideoEditView.h
//  videoedit
//
//  Created by lsq on 2017/7/25.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^switchValue)(float,float);
@interface VideoEditView : UIView

@property (nonatomic, assign) float startSecond;
@property (nonatomic, assign) float cropSecond;
@property (nonatomic, copy) switchValue switchValueBlock;

- (instancetype)initWithImageArr:(NSMutableArray <UIImage *>*)imageArr duration:(float)time frame:(CGRect)frame;

- (void)setProgress:(float)value;

@end
