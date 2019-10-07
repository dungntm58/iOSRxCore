//
//  RequestAPI+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Alamofire

public extension RequestAPI {
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    var cacheTimeoutInterval: TimeInterval {
        return 0
    }

    var extraParams: Parameters? {
        return nil
    }

    var extraHeaders: HTTPHeaders? {
        return nil
    }

    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
