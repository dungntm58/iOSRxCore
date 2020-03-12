//
//  AppCollectionView.swift
//  RxCoreList
//
//  Created by Robert on 3/27/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseCollectionView: UICollectionView {
    public typealias DataViewSource = StrictListViewSource & BindableCollectionViewDataSource

    private(set) public lazy var viewSource: DataViewSource? = _initViewSource()

    private func _initViewSource() -> DataViewSource? {
        let viewSource = initializeViewSource()
        viewSource?.register(in: self)
        return viewSource
    }

    open func initializeViewSource() -> DataViewSource? { nil }
}
