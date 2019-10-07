//
//  ModelRepository.swift
//  CoreBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import RxSwift
import RxCoreBase

public protocol ModelRepository {
    associatedtype T
}

public protocol SingleModelRepository: ModelRepository {
    func update(_ value: T, options: FetchOptions?) -> Observable<T>
    func create(_ value: T, options: FetchOptions?) -> Observable<T>
    func delete(_ value: T, options: FetchOptions?) -> Observable<Bool>
}

public protocol ListModelRepository: ModelRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>>
}

public protocol IdentifiableSingleRepository: SingleModelRepository where T: Identifiable {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T>
    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Bool>
}
