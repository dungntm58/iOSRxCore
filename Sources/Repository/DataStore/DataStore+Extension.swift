//
//  DataStore+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift
import RxCoreBase

public extension DataStore {
    var ttl: TimeInterval {
        return 0
    }

    func saveAsync(_ value: T) -> Observable<T> {
        return .create {
            subscribe in
            do {
                try self.saveSync(value)
                #if DEBUG
                Swift.print("Save \(value) of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(value)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func saveAsync(_ values: [T]) -> Observable<[T]> {
        return .create {
            subscribe in
            do {
                try self.saveSync(values)
                #if DEBUG
                Swift.print("Save \(values.count) items of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(values)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func deleteAsync(_ value: T) -> Observable<Bool> {
        return .create {
            subscribe in
            do {
                let r = try self.deleteSync(value)
                #if DEBUG
                Swift.print("Delete \(value) of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func getListAsync(options: DataStoreFetchOption) -> Observable<ListDTO<T>> {
        return .create {
            subscribe in
            do {
                let results = try self.getList(options: options)
                #if DEBUG
                Swift.print("Get \(results.data.count) items of type \(T.self) from cache successfully!!!")
                #endif
                subscribe.onNext(results)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func eraseAsync() -> Observable<Bool> {
        return .create {
            subscribe in
            do {
                let r = try self.eraseSync()
                #if DEBUG
                Swift.print("Erase all items of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }
}

public extension IdentifiableDataStore {
    func deleteSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> Bool {
        guard let value = try? getSync(id, options: options) else {
            return false
        }
        return try deleteSync(value)
    }

    func getAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<T> {
        return .create {
            subscribe in
            do {
                let value = try self.getSync(id, options: options)
                #if DEBUG
                Swift.print("Get \(value) of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(value)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func deleteAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<Bool> {
        return .create {
            subscribe in
            do {
                let r = try self.deleteSync(id, options: options)
                #if DEBUG
                Swift.print("Delete item of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }
}
