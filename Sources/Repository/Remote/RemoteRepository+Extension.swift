//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension RemoteListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        var remote: Observable<ListDTO<T>> = listRequest
            .getList(options: options?.requestOptions)
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
        remote = remote.do(onNext: {
            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
        })
        #endif
        return remote
    }
}

public extension RemoteSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap { $0.result }
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap { $0.result }
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(value, options: options?.requestOptions)
            .map { _ in () }
    }
}

public extension RemoteIdentifiableSingleRepository {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap { $0.result }
    }

    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(id: id, options: options?.requestOptions)
            .map { _ in () }
    }
}
