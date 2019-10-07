//
//  RemoteLocalRepository+Extension.swift
//  CoreRemoteRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift
import RxCoreBase
import RxCoreRequest
import RxCoreRepository

public extension RemoteLocalListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        let remote = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
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
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                return .error(NSError(domain: "DataStoreError", code: 999, userInfo: [
                    NSLocalizedDescriptionKey: "DataStore options must be set"
                    ]))
            }
            let remoteThenDataStore = remote
                .do(onNext: {
                    list in
                    try self.store.saveSync(list.data)
                })
            return store
                .getListAsync(options: cacheOptions)
                .catchError { _ in remoteThenDataStore }
                .filter { !$0.data.isEmpty }
                .ifEmpty(switchTo: remoteThenDataStore)
        case .forceRefresh(let ignoreDataStoreFailure):
            return remote
                .do(onNext: {
                    list in
                    if ignoreDataStoreFailure {
                        _ = try? self.store.saveSync(list.data)
                    } else {
                        try self.store.saveSync(list.data)
                    }
                })
        case .ignoreDataStore:
            return remote
        }
    }
}

public extension RemoteLocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        return singleRequest
            .create(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
            .map(store.saveSync)
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        return singleRequest
            .update(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
            .map(store.saveSync)
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Bool> {
        let cacheObservable = store.deleteAsync(value)
        let remote = singleRequest.delete(value, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _, cache in cache }
    }
}

public extension RemoteLocalIdentifiableSingleRepository {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T> {
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard ignoreDataStoreFailure else {
                return remote.map(store.saveSync)
            }
            return remote
                .do (onNext: {
                    value in
                    _ = try? self.store.saveSync(value)
                })
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return .first(cacheObservable, remote)
        case .ignoreDataStore:
            return remote
        }
    }

    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Bool> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _, cache in cache }
    }
}

public extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.IDType) -> FetchOptions?) -> Observable<ListDTO<T>> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return .from(optional: list)
        }
        let pagination = list.pagination
        let singleObservables = list.data.map {
            item -> Observable<T> in
            if item.isValid {
                return .from(optional: item)
            } else {
                return self.get(id: item.id, options: optionsGenerator(item.id))
            }
        }
        return Observable.concat(singleObservables)
            .toArray()
            .map { ListDTO<T>(data: $0, pagination: pagination) }
            .asObservable()
    }
}
