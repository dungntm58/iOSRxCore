//
//  Router.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 6/5/19.
//

public protocol Lauchable {
    /// Perform the scene as the root
    /// Can be called multiple times
    func launch()
}

public extension Lauchable where Self: Scenable {
    func launch() {
        perform()
        if isPerformed { return }
        updateLifeCycle(.didBecomeActive)
    }
}
