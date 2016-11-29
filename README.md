#Runtime Note
###OC 方法的本质是给接收者发送消息
如果消息接收者能够找到对应的 `selector`，那么就相当于直接执行了接收者这个对象的特定方法；</br>
否则，消息要么被转发，</br>
或者临时向接收者动态添加这个 `selector` 对应的实现内容，</br>
要么干脆玩完崩溃掉。</br>

###运行时能做什么?
1.创建,修改,自省 `class` 和 `object`</br>
2.消息分发

###Objc 在三种层面上与 Runtime 系统进行交互
1.通过 `bjective-C` 源代码<br>
2.通过 `Foundation` 框架的 `NSObject` 类定义的方法<br>
3.通过对 `Runtime` 库函数的直接调用<br>

###运行时会发消息给对象,一个对象的 class 保存了方法列表,这些消息是如何映射到方法的?这些方法是如何被执行的?
1.`class` 的方法列表其实是一个字典，`key` 为 `selectors` ， `IMPs` 为 `value`。</br>
一个 `IMP` 是指向方法在内存中的实现。很重要的一点是，`selector` 和 `IMP` <br>之间的关系是在运行时才决定的。而不是编译时，这样我们就可以玩出一点花样。<br>
2.`IMP` 通常是指向方法的指针，第一个参数是 `self` ，类型为 `id`；第二个参数是 `_cmd`，</br>
类型为 `SEL`，余下的是方法的参数。这也是 `self` 和 `_cmd` 被定义的地方。
```Objective-c
- (id)doSomethingWithInt:(int)aInt { };
id doSomethingWithInt(id self,SEL _cmd,int aInt) { };
```

###IMP
在 `Objc.h` 中的定义是:
```Objective-C
typedef id(*IMP)(id,SEL,...)
```
这是一个函数指针,这是由编译器生成的.当你发起一个 `Objc` 消息之后,最终他会执行那段代码,就是由这个函数指针指定的.而 `IMP` 你这个函数指针就指向了这个方法的实现.<br>
如果得到了执行某个实例某个方法的入口,我们就可以绕开消息传递阶段,直接执行方法,这在后面的 `Cache` 会提到.<br>
你会发现 `IMP` 指向的方法与 `objc_msgSend` 函数类型相同,参数都包含 `id` 和 `SEL` 类型.每个方法都对应一个 SEL 类型的方法选择器,每个实例对象中的 `SEL` 对应的方法实现肯定是唯一的,通过一组 `id` 和 `SEL` 参数就能确定唯一的方法实现地址.<br>
而一个确定的方法也只有唯一的一组 `id` 和 `SEL` 参数

###Cache
```Objective-C
typedef struct objc_cache *Cache
struct objc_cache {
	unsigned int mask   /* total = mask + 1 */    	  OBJC2_UNAVAILABLE;
	unsigned int occupied                             OBJC2_UNAVAILABLE;
	Method buckets [1]                                OBJC2_UNAVAILABLE;
}
```
`Cache` 为方法调用的性能进行优化，每当实例对象接收到一个消息时，它不会直接在 `isa` 指针指向的类的方法列表中遍历查找能够响应的方法，因为每次都要查找效率太低了，而是优先在 `Cache` 中查找。<br>
`Runtime` 系统会把被调用的方法存到 `Cache` 中，如果一个方法被调用，那么它有可能今后还会被调用，下次查找的时候效率更高

###runtime 如何找到方法
消息机制原理：对象根据方法编号 `SEL` 去映射表查找对应的方法实现

###找不到方法时怎么转发
消息接收者没有找到对应的方法时候，会先调用此方法，可在此方法视线中动态添加新的方法
如果返回 `NO` 或者直接返回了 `YES` 而没有添加新的方法，该方法被调用

###消息发送步骤：
1. 检测这个 `selector` 是不是要忽略的
2. 检测这个 `target` 是不是 `nil` 对象。`Objective - C` 的特性是允许对一个 nil 对象执行任何一个方法不会 crash ，因为会被忽略掉
3. 如果1、2都过了，那就开始查找这个类的 `IMP`，先从 `cache` 里面找，找得到就跳到对应的函数去执行
4. 如果 `cache` 找不到就去 `class` 的方法列表找
5. 如果 `class` 中的方法列表找不到就去父类的方法列表找，一直找，直到找到 `NSObject` 类为止
6. 如果还找不到就要开始进入动态方法解析了

###动态方法解析
1. 当一个消息发送过程中，如果找不到对应方法的实现，便会进行动态方法解析，可让我们动态绑定方法实现<br>
   例子：声明一个方法不实现就直接调用
2. 正常情况下，由于没有方法实现，程序奔溃。然而，我们可以通过分别重载 `resolveInstanceMethod:` 和 `resolveClassMethod:` 方法分别添加实例方法和类方法实现
3. 因为 `runtime` 系统在 `Cache` 中和 `Class` 的方法列表（包括父类）中找不到要执行的方法是，`Runtime` 会调用 `resolveInstanceMethod:` 或 `resolveClassMethod:` 来给程序员一次动态添加方法实现的机会<br>
```Objective-c
+( BOOL )resolveInstanceMethod:(SEL) aSEL {
     if (aSEL == @selector(xxx1) {
         class_addMethod ([self class], aSEL, (IMP)xxx2, "v@:");   
         //参数是 Type Encoding, v = void，若 i = int,
         //详见官方文档
         return YES;
     }
     return [super resolveInstanceMethod:aSEL];
}
```
<a href="https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html">官方文档</a><br>
动态方法解析的前提：<br>
前提是没有找到对应方法的实现，runtime 才会调用 `resolveInstanceMethod:` 或 `resolveClassMethod:`
如果 `responseToSelector:` 或 `instancesRespondToSelector:` 方法被执行，动态方法解析器将会被首先给予一个提供方法选择器对应的 IMP 的机会
动态方法解析会在消息转发机制浸入前执行，
如果你想让该方法选择器被传送到转发机制，那么就让 `resolveInstanceMethod:` 返回 NO

###消息转发
一、重定向<br>
1.在消息转发机制执行前，`runtime` 系统会再给我们一次偷梁换柱的机会，即通过重载 `- (id)forwardingTargetForSelector:(SEL)aSEL` 方法替换消息的接收者为其他对象<br>
2.前提是，先让 `resolveInstanceMethod:` 返回` NO`，才会被调用  `- (id)forwardingTargetForSelector:(SEL)aSEL`，毕竟消息转发要耗费更多时间，抓住这次机会将消息重定向给别人是不错的选择
如果此方法返回 `nil` 或 `self`，则会进入消息转发机制 `forwardInvocation:`,否则将向返回的对象重新发送消息

二、转发<br>
当动态方法解析不作任何处理返回 `NO` 时，则会调用 `forwardingTargetForSelector` 更改接收者，若返回 `nil` 或 `self`，消息转发机制会被触发。这时 `forwardInvocation:` 方法会被执行，可以重写这个方法来定义我们的转发逻辑<br>
Example:
```objective-c
-(void)forwardInvocation:(NSInvocation *)anInvocation {
    id someObject = [Object new];
    if ([someObject respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:someObject]; 
    }else{
        [super forwardInvocation:anInvocation]; 
    }
}
```
该消息的唯一参数是个 `NSInvocation` 类型的对象，该对象封装了原始的消息和消息的参数，我们可以实现 `forwardInvocation：` 方法来对不能处理的消息作一些默认的处理，也可以将消息转发给其他对象来处理，而不抛出错误；
这里需要注意的是，`anInvocation` 参数是从哪里来的<br>
其实在 `forwardInvocation：`消息发送前，`runtime` 系统会像对象发送 `methodSignatureForSelector: `消息，并取到返回的方法签名用于生成 `NSInvocation` 对象，所以在重写 `forwardInvocation：`的同时也要重写 `methodSignatureForSelector:` 并返回不为空的 `methodSignature`，否则会 `crash`
```Objective-c
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
     if(aSelector == @selector(xxx)) {
         //Type Encoding: v -> void       @ -> id     : -> SEL
         return [NSMethodSignature signatureWithObjcTypes:"v@:"];
     }else{
         return [super methodSignatureForSelector:aSelector]; 
     }
}
```
转发与继承相似，可以用于为 `Objective-C` 编程添加一些多继承的效果
尽管转发很想继承，但是 `NSObject` 类不会讲两者混淆，像 `respondsToSelector：` 和 `isKindOfClass:` 这类方法只会考虑继承体系，不会考虑转发链
