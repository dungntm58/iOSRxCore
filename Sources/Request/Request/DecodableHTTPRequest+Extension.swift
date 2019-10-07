//
//  DecodableHTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Alamofire

public extension DecodableHTTPRequest {
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
