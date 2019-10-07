//
//  ListAction.swift
//  CoreList
//
//  Created by Robert Nguyen on 6/8/19.
//

import RxCoreRedux
import RxCoreBase

public protocol ListActionType: ErrorActionType {
    static var updateListState: Self { get }
    static var load: Self { get }
} 
