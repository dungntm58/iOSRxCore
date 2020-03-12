//
//  UIViewControllerViewManagerProxyDelegate.h
//  RxCoreBase
//
//  Created by Robert on 2/1/20.
//

#ifndef UIViewControllerViewManagerProxyDelegate_h
#define UIViewControllerViewManagerProxyDelegate_h

#import <UIKit/UIKit.h>

@protocol UIViewControllerViewManagerProxyDelegate

- (void)viewControllerWillAppear: (nonnull UIViewController *)viewController;
- (void)viewControllerWillDisappear: (nonnull UIViewController *)viewController;

@end

#endif /* UIViewControllerViewManagerProxyDelegate_h */
