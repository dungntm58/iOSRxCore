//
//  Scene.swift
//  CoreBaseExtension
//
//  Created by Robert on 8/15/19.
//

import RxCoreBase
import RxCoreRedux

public protocol SceneBindable {
    func bind(to scene: Scenable)
}

public protocol ConnectedAdaptable {
    func activate()
    func deactivate()
}

public protocol SceneRef: class {
    associatedtype S: Scenable

    var scene: S? { set get }
}

public protocol ConnectedSceneRef: SceneRef where S: Connectable {}

public protocol SceneBindableRef: SceneBindable, SceneRef {}
public protocol ConnectedSceneBindableRef: SceneBindableRef, ConnectedSceneRef, ConnectedAdaptable {}

public extension SceneBindable where Self: SceneRef {
    func bind(to scene: Scenable) {
        self.scene = scene as? S
    }
}

public extension ConnectedAdaptable where Self: ConnectedSceneRef {
    func activate() {
        scene?.store.activate()
    }

    func deactivate() {
        scene?.store.deactivate()
    }
}

public extension Scenable {
    var nearestViewable: Viewable? {
        guard var currentScene = previous ?? parent else { return nil }
        if let viewable = currentScene as? Viewable {
            return viewable
        }
        while let scene = currentScene.previous ?? currentScene.parent {
            if let viewable = currentScene as? Viewable {
                return viewable
            }
            currentScene = scene
        }
        return nil
    }
}
