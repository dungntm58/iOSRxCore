//
//  Connected.swift
//  CoreBaseExtension
//
//  Created by Robert Nguyen on 6/8/19.
//

import RxSwift
import RxCoreRedux
import RxCoreBase

open class ConnectableScene<Store>: Scene, Connectable where Store: Storable {
    public let store: Store

    public init(store: Store, managedContext: ManagedSceneContext = ManagedSceneContext()) {
        self.store = store
        super.init(managedContext: managedContext)
        let lifeCycleDiposable = self.lifeCycle
            .map {
                state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            }
            .distinctUntilChanged()
            .subscribe(
                onNext: {
                    [store] shouldActiveStore in
                    shouldActiveStore ? store.activate() : store.deactivate()
                }
            )
        _ = managedContext.insertDisposable(lifeCycleDiposable)
    }
}

open class ViewableScene: Scene, Viewable {
    public var viewManager: ViewManagable

    public init(managedContext: ManagedSceneContext = ManagedSceneContext(), viewManager: ViewManagable) {
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
    }

    public init(managedContext: ManagedSceneContext = ManagedSceneContext(), viewController: UIViewController) {
        let viewManager = ViewManager(viewController: viewController)
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        viewManager.bind(scene: self)
    }

    open override func onDetach() {
        viewManager.dismiss(animated: true, completion: nil)
    }
}

open class ConnectableViewableScene<Store>: Scene, Connectable, Viewable where Store: Storable {
    public let store: Store
    public let viewManager: ViewManagable

    public init(managedContext: ManagedSceneContext = ManagedSceneContext(), store: Store, viewManager: ViewManagable) {
        self.store = store
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        self.config()
    }

    public init(managedContext: ManagedSceneContext = ManagedSceneContext(), store: Store, viewController: UIViewController) {
        self.store = store
        let viewManager = ViewManager(viewController: viewController)
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        viewManager.bind(scene: self)
        self.config()
    }

    open override func onDetach() {
        viewManager.dismiss(animated: true, completion: nil)
    }
}

private extension ConnectableViewableScene {
    func config() {
        let lifeCycleDiposable = self.lifeCycle
            .map {
                state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            }
            .distinctUntilChanged()
            .subscribe(onNext: {
                [store] shouldActiveStore in
                shouldActiveStore ? store.activate() : store.deactivate()
            })
        _ = managedContext.insertDisposable(lifeCycleDiposable)
    }
}
