//
//  ExchangeMethodController.m
//  Runtime
//
//  Created by CC on 2016/11/29.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ExchangeMethodController.h"
#import "ExchangeView.h"
#import <objc/runtime.h>

@interface ExchangeMethodController ()

@end

@implementation ExchangeMethodController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutUI];
    [self exchangeMethod];
}

#pragma mark -- 新的方法
- (void)newMethod {
    NSLog(@"交换后新的方法");
}

#pragma mark -- 交换方法
- (void)exchangeMethod {
    Method oldSel = class_getInstanceMethod([ExchangeView class], @selector(click));
    Method newSel = class_getInstanceMethod([self class], @selector(newMethod));
    method_exchangeImplementations(oldSel, newSel);
}

#pragma mark -- 添加 View
- (void)layoutUI {
    ExchangeView *exchangeView = [[ExchangeView alloc]initWithFrame:CGRectMake((KScreenWidth - 300)/2, 200, 300, 100)];
    [self.view addSubview:exchangeView];
}

@end
