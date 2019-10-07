//
//  HTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import RxSwift
import RxCoreBase

public extension HTTPRequest {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    func execute(api: API, options: RequestOption?) -> Observable<Response>{
        return pureExecute(api: api, options: options).map(transform)
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    func upload(api: API, options: UploadRequestOption) -> Observable<Response> {
        return pureUpload(api: api, options: options).map(transform)
    }
}
