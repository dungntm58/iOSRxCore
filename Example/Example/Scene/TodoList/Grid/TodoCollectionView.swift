//
//  TodoCollectionView.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreBase
import RxCoreList
import Toaster

class TodoCollectionView: BaseCollectionView, Appearant {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
    }
    
    var store: TodoStore? {
        return (viewController as? TodoList2ViewController)?.scene?.store
    }
    
    override func initializeViewSource() -> DataViewSource? {
        return TodoList2ViewSource(store: store)
    }
}
