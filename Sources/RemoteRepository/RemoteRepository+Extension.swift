//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift
import RxCoreBase
import RxCoreRepository

public extension RemoteListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        return listRequest
            .getList(options: options?.requestOptions)
            .map {
                response -> ListDTO<T> in
                #if DEBUG
                let list = response.results!
                Swift.print("Get \(list.count) items of type \(T.self) from remote successfully!!!")
                return ListDTO<T>(data: list, pagination: response.pagination)
                #else
                return ListDTO<T>(data: response.results!, pagination: response.pagination)
                #endif
        }
    }
}

public extension RemoteSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        return singleRequest
            .create(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        return singleRequest
            .update(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Bool> {
        return singleRequest
            .delete(value, options: options?.requestOptions)
            .map { _ in true }
    }
}

public extension RemoteIdentifiableSingleRepository {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T> {
        return singleRequest
            .get(id: id, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Bool> {
        return singleRequest
            .delete(id: id, options: options?.requestOptions)
            .map { _ in true }
    }
}
