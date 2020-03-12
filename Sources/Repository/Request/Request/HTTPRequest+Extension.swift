//
//  HTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Alamofire
import RxSwift

public extension HTTPRequest {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    func execute(api: API, options: RequestOption?) -> Observable<Response>{
        pureExecute(api: api, options: options).map(transform)
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    func upload(api: API, options: UploadRequestOption) -> Observable<Response> {
        pureUpload(api: api, options: options).map(transform)
    }
}

public extension HTTPRequest where Self: Decoding, Response: Decodable {
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
