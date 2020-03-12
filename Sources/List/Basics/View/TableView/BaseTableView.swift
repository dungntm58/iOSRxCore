//
//  AppTableView.swift
//  RxCoreList
//
//  Created by Robert on 2/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseTableView: UITableView {
    public typealias DataViewSource = StrictListViewSource & BindableTableViewDataSource

    private(set) public lazy var viewSource: DataViewSource? = _initViewSource()

    private func _initViewSource() -> DataViewSource? {
        let viewSource = initializeViewSource()
        viewSource?.register(in: self)
        return viewSource
    }

    open func initializeViewSource() -> DataViewSource? { nil }
}
