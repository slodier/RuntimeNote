//
//  ExchangeView.m
//  Runtime
//
//  Created by CC on 2016/11/29.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ExchangeView.h"

@implementation ExchangeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self layoutUI];
    }
    return self;
}

#pragma mark -- 按钮点击
- (void)click {
    NSLog(@"这是原本的方法");
}

#pragma mark -- 构建 UI
- (void)layoutUI {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.bounds;
    btn.backgroundColor = [UIColor greenColor];
    [self addSubview:btn];
    [btn setTitle:@"我是一个按钮" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

@end
