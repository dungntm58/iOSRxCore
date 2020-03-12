//
//  TodoList2ViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase

class TodoList2ViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: TodoCollectionView!
    
    weak var scene: TodoScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = (tabBarController as? TodoTabBarController)?.scene
        
        // Do any additional setup after loading the view.
    }
    
}
