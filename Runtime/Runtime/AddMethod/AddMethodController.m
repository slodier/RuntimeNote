//
//  AddMethodController.m
//  Runtime
//
//  Created by CC on 2016/11/28.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "AddMethodController.h"
#import <objc/runtime.h>

@interface AddMethodController ()

@end

@implementation AddMethodController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutUI];
}

#pragma mark -- 动态添加新的方法，代替未实现的方法
void addMethod (id self,SEL _cmd){
    NSLog(@"这是动态添加的方法");
}

#pragma mark -- 重写方法
/*
    OC 方法的本质是给接收者发送消息
    如果消息接收者能够找到对应的 selectot,那么就相当于直接执行了接收者这个对象的特定方法;
    否则消息要么被转发,或者临时向接收者动态添加这个 selector 对应的实现内容,要么 crash.
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(click)) {
        class_addMethod([self class], sel, (IMP)addMethod, "v@:");
    }
    return [super resolveClassMethod:sel];
}

#pragma mark -- 添加一个未实现方法的按钮
- (void)layoutUI {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((KScreenWidth - 300)/2, 200, 300, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn setTitle:@"未实现方法的按钮" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

@end
