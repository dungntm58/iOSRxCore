//
//  Util+Internal.m
//  RxCoreBase
//
//  Created by Robert on 1/27/20.
//

#import <objc/runtime.h>
#import <Util+Internal.h>

@implementation Util

+ (void)swizzling: (Class)swizzedClass originalSelector: (SEL)originalSelector swizzledSelector: (SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(swizzedClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzedClass, swizzledSelector);

    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

    BOOL didAddMethod =
    class_addMethod(swizzedClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(swizzedClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
