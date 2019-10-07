//
//  ViewManager.swift
//  CoreBaseExtension
//
//  Created by Robert on 7/21/19.
//

import RxSwift
import RxRelay
import RxCocoa
import RxCoreBase

public class ViewManager: ViewManagable {
    private lazy var disposeBag = DisposeBag()

    private var _currentViewController: UIViewController?
    private var rootViewController: UIViewController
    fileprivate weak var scene: Scene?

    public init(viewController: UIViewController) {
        self.rootViewController = viewController
        self.addHook(viewController)
    }

    private(set) public var currentViewController: UIViewController {
        set {
            if _currentViewController != nil {
                _currentViewController = newValue
            }
        }
        get {
            return _currentViewController ?? rootViewController
        }
    }

    public func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if DEBUG
        print("Present view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.present(viewController, animated: true, completion: completion)
    }

    public func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        addHook(viewController)
        #if DEBUG
        print("Push view controller", type(of: viewController))
        #endif
        (self.currentViewController as? UINavigationController ?? self.currentViewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    public func show(_ viewController: UIViewController, sender: Any? = nil) {
        #if DEBUG
        print("Show view controller", type(of: viewController))
        #endif
        addHook(viewController)
        self.currentViewController.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        #if DEBUG
        print("Dismiss root view controller")
        #endif
        internalDismiss(from: rootViewController, animated: flag, completion: completion)
    }

    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        #if DEBUG
        print("Dismiss current view controller")
        #endif
        internalDismiss(from: currentViewController, animated: flag, completion: completion)
    }
}

extension ViewManager {
    func bind(scene: Scene) {
        self.scene = scene
        if let bindable = rootViewController as? SceneBindable {
            bindable.bind(to: scene)
        }
        if let bindable = _currentViewController as? SceneBindable {
            bindable.bind(to: scene)
        }
    }
}

private extension ViewManager {
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

    func addHook(_ viewController: UIViewController) {
        if let scene = scene, let bindable = viewController as? SceneBindable {
            bindable.bind(to: scene)
        }
        let disposables = CompositeDisposable()
        _ = disposables.insert(
            Observable.combineLatest(
                viewController
                    .rx
                    .methodInvoked(#selector(UIViewController.viewWillAppear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .subscribe(onNext: {
                [weak self] vc in
                self?.currentViewController = vc
                if let bindable = vc as? ConnectedAdaptable {
                    bindable.activate()
                }
            })
        )
        _ = disposables.insert(
            Observable.combineLatest(
                viewController
                    .rx
                    .methodInvoked(#selector(UIViewController.viewWillDisappear(_:))),
                Observable.just(viewController)
            ) { $1 }
            .subscribe(onNext: {
                [weak self] vc in
                self?._currentViewController = nil
                if let sceneBindable = vc as? ConnectedAdaptable {
                    sceneBindable.deactivate()
                }
            })
        )
        disposables.disposed(by: disposeBag)
    }
}
