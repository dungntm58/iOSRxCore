//
//  RemoteLocalRepository+Extension.swift
//  CoreRemoteRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension RemoteLocalListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        var remote: Observable<ListDTO<T>> = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
        remote = remote.do(onNext: {
            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
        })
        #endif
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                assertionFailure("DataStore options must be set")
                return .empty()
            }
            let remoteThenDataStore = remote
                .do(onNext: { try self.store.saveSync($0.data) })
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
        #if swift(>=5.2)
        return singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
            .map(store.saveSync)
        #else
        return singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap { $0.result }
            .map(store.saveSync)
        #endif
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        #if swift(>=5.2)
        return singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
            .map(store.saveSync)
        #else
        return singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap { $0.result }
            .map(store.saveSync)
        #endif
        
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        let cacheObservable = store.deleteAsync(value)
        let remote = singleRequest.delete(value, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _,_ in }
    }
}

public extension RemoteLocalIdentifiableSingleRepository {
    func get(id: T.IDType, options: FetchOptions?) -> Observable<T> {
        #if swift(>=5.2)
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)
        #else
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap { $0.result }
        #endif

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard ignoreDataStoreFailure else {
                return remote.map(store.saveSync)
            }
            return remote
                .do(onNext: { _ = try? self.store.saveSync($0) })
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return .first(cacheObservable, remote)
        case .ignoreDataStore:
            return remote
        }
    }

    func delete(id: T.IDType, options: FetchOptions?) -> Observable<Void> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _, _ in }
    }
}

public extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.IDType) -> FetchOptions?) -> Observable<ListDTO<T>> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return .from(optional: list)
        }
        let singleObservables = list.data.map {
            item -> Observable<T> in
            if item.isValid {
                return .from(optional: item)
            } else {
                return self.get(id: item.id, options: optionsGenerator(item.id))
            }
        }
        #if swift(>=5.2)
        let idsObservable = Observable.deferred { .just(list.data.map(\.id )) }
        #else
        let idsObservable = Observable.deferred { .just(list.data.map { $0.id }) }
        #endif
        return .zip(
            Observable.just(list.pagination),
            idsObservable,
            Observable.merge(singleObservables)
                .toArray()
                .asObservable()
        ) {
            pagination, ids, arr in
            ListDTO<T>(
                data: ids.compactMap { id in arr.first(where: { $0.id == id }) },
                pagination: pagination
            )
        }
    }
}
