//
//  AppTableView.swift
//  CoreList
//
//  Created by Robert on 2/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

open class BaseTableView: UITableView {
    public typealias DataViewSource = StrictListViewSource & BindableTableViewDataSource & UITableViewDelegate

    public var viewSource: DataViewSource? {
        didSet {
            viewSource?.register(in: self)
        }
    }
}
