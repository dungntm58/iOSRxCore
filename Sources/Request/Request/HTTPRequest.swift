//
//  HTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Alamofire

public protocol HTTPRequest: class, PureHTTPRequest {
    associatedtype Response: HTTPResponse

    /// Generic transform data generator
    func transform(dataResponse: DataResponse<Data>) throws -> Response
}
