//
//  DataRequestOption.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

public protocol FetchOptions {
    var requestOptions: RequestOption? { get }
    var repositoryOptions: RepositoryOption { get }
    var storeFetchOptions: DataStoreFetchOption { get }
}

public protocol RequestOption {
    var parameters: [String: Any]? { get }
}

public extension Dictionary where Key == String {
    var parameters: [String: Any]? {
        return self
    }
}

public enum RepositoryOption {
    case ignoreDataStore
    case forceRefresh(ignoreDataStoreFailure: Bool)
    case `default`
}

public enum DataStoreFetchOption {
    public enum Sorting {
        case asc(property: String)
        case desc(property: String)
        case automatic
    }

    case automatic
    case predicate(_ predicate: NSPredicate, limit: Int, sorting: Sorting, validate: Bool)
    case page(_ page: Int, size: Int, predicate: NSPredicate?, sorting: Sorting, validate: Bool)
}
