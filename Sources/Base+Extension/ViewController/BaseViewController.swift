//
//  BaseViewController.swift
//  CoreBaseExtension
//
//  Created by Robert on 1/10/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public typealias AttachedView = UIView & Appearant

open class BaseCleanViewController: UIViewController {
    private(set) public var attachedViews: [AttachedView] = []
    private(set) public var isViewAppeared: Bool = false

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isViewAppeared {
            attachedViews.forEach {
                $0.willReappear?()
            }
        } else {
            attachedViews.forEach {
                $0.willAppear?()
            }
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isViewAppeared {
            attachedViews.forEach {
                $0.didReappear?()
            }
        } else {
            attachedViews.forEach {
                $0.didAppear?()
            }
        }
        isViewAppeared = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        attachedViews.forEach {
            $0.willDisappear?()
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attachedViews.forEach {
            $0.didDisappear?()
        }
    }

    public func add(attachedView: AttachedView) {
        attachedViews.append(attachedView)
    }

    public func remove(attachedView: AttachedView) {
        // ??? I don't know why swift compiler can not compile this code
        // let index = attachedViews.firstIndex(of: attachedView)
        if let index = attachedViews.firstIndex(where: { $0.isEqual(attachedView) }) {
            attachedViews.remove(at: index)
        }
    }
}
