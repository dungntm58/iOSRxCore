//
//  ListDataWorker.swift
//  CoreList
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import RxCoreBase

public protocol PaginationRequestOptions: FetchOptions {}

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

public protocol ListDataWorker {
    associatedtype T

    func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<T>>
}
