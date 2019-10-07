//
//  Util+Extension.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public struct Util {
    public static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    public static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    public static func makeFetchOptions(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) -> FetchOptions {
        return InternalFetchOptions(requestOptions: requestOptions, repositoryOptions: repositoryOptions, storeFetchOptions: storeFetchOptions)
    }
}
