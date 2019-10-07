//
//  AppCollectionView.swift
//  CoreList
//
//  Created by Robert on 3/27/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseCollectionView: UICollectionView {
    public typealias DataViewSource = StrictListViewSource & BindableCollectionViewDataSource & UICollectionViewDelegate

    public var viewSource: DataViewSource? {
        didSet {
            viewSource?.register(in: self)
        }
    }
}
