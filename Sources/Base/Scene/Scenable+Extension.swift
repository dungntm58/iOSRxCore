//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

// Shortcut
public extension Scenable {
    internal(set) var previous: Scenable? {
        set { managedContext.previous = newValue }
        get { return managedContext.previous }
    }

    internal(set) var children: [Scenable] {
        set { managedContext.children = newValue }
        get { return managedContext.children }
    }

    internal(set) var parent: Scenable? {
        set { managedContext.parent = newValue }
        get { return managedContext.parent }
    }

    internal(set) var isPerformed: Bool {
        set { managedContext.isPerformed = newValue }
        get { return managedContext.isPerformed }
    }

    /// The nearest child scene that has been performed
    internal(set) var current: Scenable? {
        set { managedContext.current = newValue }
        get { return managedContext.current }
    }
}

// Convenience
public extension Scenable {
    /// Return an observable instance that observe life cycle of this scene.
    var lifeCycle: Observable<LifeCycle> {
        return managedContext.lifeCycle.asObservable()
    }

    /// Return the current value of life cycle
    func getLifeCycleState() throws -> LifeCycle {
        return try managedContext.lifeCycle.value()
    }

    /// The most leaf child scene that has been performed
    var visible: Scenable {
        var currentScene: Scenable = self
        while let scene = currentScene.current {
            currentScene = scene
        }
        return currentScene
    }

    /// The parent or one of its ancestor
    var ancestor: Scenable? {
        guard var currentScene = parent else { return nil }

        while let scene = currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    var root: Scenable? {
        guard var currentScene = previous ?? parent else { return nil }

        while let scene = currentScene.previous ?? currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }
}

extension Scenable {
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.onNext(value)
    }
}
