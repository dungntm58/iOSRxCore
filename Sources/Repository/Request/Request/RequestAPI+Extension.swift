//
//  RequestAPI+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Alamofire

public extension RequestAPI {
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var cacheTimeoutInterval: TimeInterval { 0 }
    var extraParams: Parameters? { nil }
    var extraHeaders: HTTPHeaders? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
