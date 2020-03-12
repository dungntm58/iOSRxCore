//
//  TodoListViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase

class TodoListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: TodoTableView!
    
    weak var scene: TodoScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = (tabBarController as? TodoTabBarController)?.scene
        
        // Do any additional setup after loading the view.
    }

}
