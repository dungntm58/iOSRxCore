//
//  FetchOptions+Internal.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

struct InternalFetchOptions: FetchOptions {
    let requestOptions: RequestOption?
    let repositoryOptions: RepositoryOption
    let storeFetchOptions: DataStoreFetchOption

    init(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) {
        self.requestOptions = requestOptions
        self.repositoryOptions = repositoryOptions
        self.storeFetchOptions = storeFetchOptions
    }
}

public extension RequestOption {
    func toFetchOptions() -> FetchOptions {
        return InternalFetchOptions(requestOptions: self)
    }
}

public extension RepositoryOption {
    func toFetchOptions() -> FetchOptions {
        return InternalFetchOptions(repositoryOptions: self)
    }
}

public extension DataStoreFetchOption {
    func toFetchOptions() -> FetchOptions {
        return InternalFetchOptions(storeFetchOptions: self)
    }
}
