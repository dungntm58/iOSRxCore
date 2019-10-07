//
//  LocalRepository+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift
import RxCoreBase

public extension LocalListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            return .error(
                NSError(
                    domain: "DataStoreError",
                    code: 999,
                    userInfo: [
                        NSLocalizedDescriptionKey: "DataStore options must be set"
                    ]
                )
            )
        }
        return store.getListAsync(options: storeFetchOptions)
    }
}

public extension LocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        return store.saveAsync(value)
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        return store.saveAsync(value)
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Bool> {
        return store.deleteAsync(value)
    }
}

public extension LocalIdentifiableSingleRepository {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T> {
        return store.getAsync(id, options: options?.storeFetchOptions)
    }

    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Bool> {
        return store.deleteAsync(id, options: options?.storeFetchOptions)
    }
}
