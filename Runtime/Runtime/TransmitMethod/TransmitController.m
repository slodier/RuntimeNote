//
//  TransmitController.m
//  Runtime
//
//  Created by CC on 2016/12/7.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "TransmitController.h"
#import "TestView.h"

@interface TransmitController ()

@end

@implementation TransmitController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self layoutUI];
}

/*
    1.消息转发需要 resolveInstanceMethod: 先返回 NO
    2.则会调用 forwardingTargetForSelector: 更改接受者,若返回 nil 或 self,消息转发机制会被
 触发
    3.这时 forwardInvocation: 会被执行
        在 forwardInvocation: 消息发送之前, runtime 系统会像对象发送
        methodSignatureForSelector: 消息,并取到返回的方法签名用于生成 NSInvocation 对象,所以
        在重写 forwardInvovation: 的同时也要重写 methodSignatureForSelector: 并且返回不为空
        的 methodSignature,否则会 crash.
 */
#pragma mark 检查对象能否处理方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(xxx)) {
        return NO;
    }
    return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(xxx)) {
        //"v@:" -- Type Encoding
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else{
        return [super methodSignatureForSelector:aSelector];
    }
}

#pragma mark -- 消息重定向
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id someObject = [TestView new];
    if ([someObject respondsToSelector:[anInvocation selector]]) {
        // 更改消息接收者为 TestView
        [anInvocation invokeWithTarget:someObject];
    }else{
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark -- layoutUI
- (void)layoutUI {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((KScreenWidth - 300)/2, 200, 300, 100);
    [btn addTarget:self action:@selector(xxx) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"消息转发的按钮" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn];
}

@end
