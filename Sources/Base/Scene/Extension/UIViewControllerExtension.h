//
//  UIViewControllerExtension.h
//  Pods
//
//  Created by Robert on 2/17/20.
//

#ifndef UIViewControllerExtension_h
#define UIViewControllerExtension_h

#import "UIViewControllerViewManagerProxyDelegate.h"

@interface UIViewController (RxCoreBase)

@property (nonatomic, weak, nullable) id<UIViewControllerViewManagerProxyDelegate> viewManagerProxyDelegate;

- (void)dismissKeyboard;
- (BOOL)canPerformSegueWithIdentifier:(nonnull NSString *)id;

@end

#endif /* UIViewControllerExtension_h */
