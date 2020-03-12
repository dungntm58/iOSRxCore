//
//  UIViewControllerExtension.m
//  RxCoreBase
//
//  Created by Robert on 2/17/20.
//

#import <UIViewControllerExtension.h>
#import <objc/runtime.h>
#import <Util+Internal.h>

@implementation UIViewController (RxCoreBase)

+ (void)load {
    Class swizzledClass = [self class];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Util swizzling:swizzledClass originalSelector: @selector(viewWillAppear:) swizzledSelector:@selector(swizzledViewWillAppear:)];
        [Util swizzling:swizzledClass originalSelector: @selector(viewWillDisappear:) swizzledSelector:@selector(swizzledViewWillDisappear:)];
    });
}

- (void)swizzledViewWillAppear: (BOOL)animated {
    [self.viewManagerProxyDelegate viewControllerWillAppear:self];
    [self swizzledViewWillAppear:animated];
}

- (void)swizzledViewWillDisappear: (BOOL)animated {
    [self.viewManagerProxyDelegate viewControllerWillDisappear:self];
    [self swizzledViewWillAppear:animated];
}

- (id<UIViewControllerViewManagerProxyDelegate>)viewManagerProxyDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewManagerProxyDelegate: (id<UIViewControllerViewManagerProxyDelegate>)viewManagerProxyDelegate {
    objc_setAssociatedObject(self,
                             @selector(viewManagerProxyDelegate),
                             viewManagerProxyDelegate,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)canPerformSegueWithIdentifier:(nonnull NSString *)identifier {
    NSArray *segues = [self valueForKey:@"storyboardSegueTemplates"];
    if (!segues) {
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSArray *filteredArray = [segues filteredArrayUsingPredicate:predicate];
    return filteredArray.count > 0;
}

@end
