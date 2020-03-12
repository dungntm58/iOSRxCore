//
//  ViewManagerProxyDelegateImpl.swift
//  RxCoreBase
//
//  Created by Robert on 2/1/20.
//

class ViewManagerProxyDelegateImpl: UIViewControllerViewManagerProxyDelegate {
    let viewManager: ViewManager

    init(viewManager: ViewManager) {
        self.viewManager = viewManager
    }

    @objc func viewControllerWillAppear(_ viewController: UIViewController) {
        viewManager.viewControllerWillAppear(viewController)
    }

    @objc func viewControllerWillDisappear(_ viewController: UIViewController) {
        viewManager.viewControllerWillDisappear(viewController)
    }
}
