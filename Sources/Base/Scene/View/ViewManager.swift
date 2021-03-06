//
//  ViewManager.swift
//  RxCoreBase
//
//  Created by Robert on 7/21/19.
//

import RxSwift
import RxCocoa

public class ViewManager {
    private var _currentViewController: UIViewController?
    private var rootViewController: UIViewController
    fileprivate weak var scene: Scenable?
    let disposeBag = DisposeBag()

    public init(viewController: UIViewController) {
        self.rootViewController = viewController
        addHook(viewController)
    }

    func bind(scene: Scenable) {
        self.scene = scene
        if let bindable = _currentViewController as? SceneBindable {
            bindable.bind(to: scene)
        }
    }

    func viewControllerWillAppear(_ viewController: UIViewController) {
        self.currentViewController = viewController
        if let scene = scene, let bindable = viewController as? SceneBindable {
            bindable.bind(to: scene)
        }
    }

    func viewControllerWillDisappear(_ viewController: UIViewController) {
        self._currentViewController = nil
    }
}

extension ViewManager: ViewManagable {
    private(set) public var currentViewController: UIViewController {
        set {
            if _currentViewController != nil {
                _currentViewController = newValue
            }
        }
        get { _currentViewController ?? rootViewController }
    }

    public func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Present view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.present(viewController, animated: true, completion: completion)
    }

    public func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Push view controller", type(of: viewController))
        #endif
        addHook(viewController)
        (self.currentViewController as? UINavigationController ?? self.currentViewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    public func show(_ viewController: UIViewController, sender: Any? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Show view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Dismiss root view controller")
        #endif
        internalDismiss(from: rootViewController, animated: flag, completion: completion)
    }

    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Dismiss current view controller")
        #endif
        internalDismiss(from: currentViewController, animated: flag, completion: completion)
    }
}

private extension ViewManager {
    func addHook(_ viewController: UIViewController) {
        Observable
            .combineLatest(
                viewController.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .subscribe(onNext: self.viewControllerWillAppear(_:))
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                viewController.rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .subscribe(onNext: self.viewControllerWillDisappear(_:))
            .disposed(by: disposeBag)
    }

    func internalDismiss(from viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let naviViewController = viewController.navigationController {
            if naviViewController.viewControllers.first == viewController {
                naviViewController.dismiss(animated: flag, completion: completion)
            } else if let completion = completion {
                naviViewController.popViewController(animated: true, completion: completion)
            } else {
                naviViewController.popViewController(animated: true)
            }
        } else if let tabbarViewController = viewController.tabBarController {
            tabbarViewController.dismiss(animated: flag, completion: completion)
        } else {
            viewController.dismiss(animated: flag, completion: completion)
        }
    }
}
