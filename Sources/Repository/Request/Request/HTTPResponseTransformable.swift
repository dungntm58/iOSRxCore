//
//  HTTPResponseTransformable.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Alamofire

public protocol HTTPResponseTransformable {
    associatedtype Response: HTTPResponse

    /// Generic transform data generator
    func transform(dataResponse: DataResponse<Data>) throws -> Response
}

public extension HTTPResponseTransformable where Self: Decoding, Response: Decodable {
    func transform(dataResponse: DataResponse<Data>) throws -> Response {
        switch dataResponse.result {
        case .success(let data):
            let httpResponse = try decoder.decode(Response.self, from: data)
            if httpResponse.success {
                return httpResponse
            } else {
                throw ResponseError(httpCode: dataResponse.response?.statusCode ?? 0, message: httpResponse.message, code: httpResponse.errorCode, data: data)
            }
        case .failure(let error):
            throw error
        }
    }
}

public protocol HTTPRequest: class, PureHTTPRequest, HTTPResponseTransformable {}
