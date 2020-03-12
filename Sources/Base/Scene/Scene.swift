//
//  Scene.swift
//  RxCoreBase
//
//  Created by Robert on 8/10/19.
//

open class Scene: Scenable {
    public let managedContext: ManagedSceneContext

    public init() {
        self.managedContext = .init()
    }

    public init(managedContext: ManagedSceneContext) {
        self.managedContext = managedContext
    }

    open func perform() {
        // No-op
    }

    open func prepare(for scene: Scenable) {
        // No-op
    }

    open func onDetach() {
        // No-op
    }

    open func forwardDataWhenDetach() -> Any {
        Optional<Any>.none as Any // Nil of any
    }

    public func `switch`(to scene: Scenable) {
        updateLifeCycle(.willResignActive)
        prepare(for: scene)
        scene.previous = self
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
        updateLifeCycle(.didResignActive)
    }

    public func attach(child scene: Scenable) {
        if children.contains(where: { scene as AnyObject === $0 as AnyObject }) {
            #if !RELEASE && !PRODUCTION
            Swift.print("This scene has been already attached")
            #endif
            if let retrieve = scene.retrieve {
                scene.updateLifeCycle(.willBecomeActive)
                retrieve(Optional<Any>.none as Any)
                current = scene
                scene.updateLifeCycle(.didBecomeActive)
            } else {
                current = scene
            }
        } else {
            children.append(scene)
            scene.updateLifeCycle(.willBecomeActive)
            prepare(for: scene)
            scene.parent = self
            scene.perform()
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
            _ = managedContext.disposables.insert(
                lifeCycle.subscribe(onNext: {
                    value in
                    scene.managedContext.lifeCycle.onNext(value)
                })
            )
        }
    }

    public func set(children: [Scenable], performAtIndex index: Int?) {
        guard let index = index else {
            return self.children = children
        }

        let scene = children[index]
        prepare(for: scene)
        self.children = children
        children.forEach {
            scene in
            scene.parent = self
            _ = managedContext.disposables.insert(
                lifeCycle.subscribe(onNext: {
                    value in
                    scene.managedContext.lifeCycle.onNext(value)
                })
            )
        }
        current = scene
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
    }

    public func detach() {
        #if !RELEASE && !PRODUCTION
        Swift.print("Detach scene", type(of: self))
        printSceneHierachyDebug()
        #endif
        if previous == nil {
            parent?.detach()
            return
        }

        let previousScene = self.previous
        updateLifeCycle(.willDetach)
        children.removeAll()
        current = nil
        previous = nil
        if let parent = parent, let selfIndex = parent.children.firstIndex(where: { $0 === self }) {
            parent.children.remove(at: selfIndex)
        }
        parent?.current = nil
        if let retrieve = previousScene?.retrieve {
            previousScene?.updateLifeCycle(.willBecomeActive)
            retrieve(forwardDataWhenDetach())
            previousScene?.updateLifeCycle(.didBecomeActive)
        }
        onDetach()
        updateLifeCycle(.didDetach)

        managedContext.disposables.dispose()
        managedContext.lifeCycle.onCompleted()
    }

    func performChild(at index: Int) {
        current?.updateLifeCycle(.willResignActive)
        let scene = children[index]
        prepare(for: scene)
        scene.perform()
        let prevScene = current
        current = scene
        prevScene?.updateLifeCycle(.didResignActive)

        if scene.isPerformed { return }
        scene.isPerformed = true
        scene.updateLifeCycle(.didBecomeActive)
    }

    #if !RELEASE && !PRODUCTION
    public func printSceneHierachyDebug() {
        Swift.print("------- Scene hierachy -------")
        guard var currentScene = previous ?? parent else { return }
        Swift.print("Scene", type(of: self), "\n    - Parent:", parent == nil ? "nil" : "\(type(of: parent as! Scene as Any))", "\n    - Previous:", previous == nil ? "nil" : "\(type(of: previous as! Scene as Any))")
        while let scene = currentScene.previous ?? currentScene.parent {
            Swift.print("Scene", type(of: currentScene), "\n    - Parent:", currentScene.parent == nil ? "nil" : "\(type(of: currentScene.parent as! Scene as Any))", "\n    - Previous:", currentScene.previous == nil ? "nil" : "\(type(of: currentScene.previous as! Scene as Any))")
            currentScene = scene
        }
        Swift.print("-----------------------------")
    }
    #endif
}
