//
//  TodoTableView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreList
import RxCoreBase

class TodoTableView: BaseTableView, Appearant {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    func configure() {
    }
    
    var store: TodoStore? {
        return (viewController as? TodoListViewController)?.scene?.store
    }
    
    override func initializeViewSource() -> BaseTableView.DataViewSource? {
        return TodoListViewSource(store: store)
    }
}
