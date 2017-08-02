//
//  VideoEditScrollerView.h
//  videoedit
//
//  Created by lsq on 2017/7/25.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoEditScrollerView : UIScrollView

- (instancetype)initWithImageArr:(NSMutableArray *)imageArr duration:(float)time frame:(CGRect)frame;

@end
