//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxCoreBase
import RxCoreBaseExtension

class SwitchScene: ViewableScene, Lauchable {
    lazy var window = UIWindow(frame: UIScreen.main.bounds)
    
    init() {
        let vc = AppStoryboard.main.viewController(of: SuperSwitcherViewController.self)
        super.init(viewManager: vc)
        vc.scene = self
    }

    override func perform() {
        window.rootViewController = currentViewController
        window.makeKeyAndVisible()
    }
}
