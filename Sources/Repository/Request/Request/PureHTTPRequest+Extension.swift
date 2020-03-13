//
//  RawHTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 5/13/19.
//

import Alamofire
import RxSwift

// MARK: - Default
public extension PureHTTPRequest {
    var defaultParams: Parameters? { nil }

    var sessionManager: SessionManager { .default }
}

// MARK: - Convenience
public extension PureHTTPRequest {
    func makeRequest(api: API, options: RequestOption?) throws -> URLRequestConvertible {
        var headers = defaultHeaders
        if let extraHeaders = api.extraHeaders {
            if let _headers = headers {
                headers = _headers + extraHeaders
            } else {
                headers = extraHeaders
            }
        }

        var requestParams = options?.parameters
        if let extraParams = api.extraParams {
            if let _requestParams = requestParams {
                requestParams = _requestParams + extraParams
            } else {
                requestParams = extraParams
            }
        }

        let urlString = "\(environment.config.defaultServerUrl)\(api.endPoint)"

        #if !RELEASE && !PRODUCTION
        Swift.print("URL", urlString)
        Swift.print("Headers", headers ?? [:])
        Swift.print("Params", requestParams ?? [:])
        #endif

        let rawRequest = try URLRequest.init(url: urlString, method: api.method, headers: headers)
        var request = try api.encoding.encode(rawRequest, with: requestParams)
        request.cachePolicy = api.cachePolicy
        request.timeoutInterval = api.cacheTimeoutInterval
        return request
    }

    func pureExecute(api: API, options: RequestOption?) -> Observable<DataResponse<Data>>{
        .create {
            subscribe in
            var dataRequest: DataRequest!
            let acceptableStatusCodes: [Int]
            if api.acceptableStatusCodes.isEmpty {
                acceptableStatusCodes = self.acceptableStatusCodes
            } else {
                acceptableStatusCodes = api.acceptableStatusCodes
            }
            do {
                let request = try self.makeRequest(api: api, options: options)
                dataRequest = self.sessionManager.request(request).validate(statusCode: acceptableStatusCodes)
                dataRequest.responseData {
                    response in
                    #if !RELEASE && !PRODUCTION
                    Swift.print(response)
                    if let data = response.data {
                        printDebug(data: data)
                    }
                    #endif
                    if let error = response.error {
                        return subscribe.onError(error)
                    }
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                }
            } catch {
                #if !RELEASE && !PRODUCTION
                Swift.print("Response error", error as NSError)
                #endif
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak dataRequest] in
                dataRequest?.cancel()
            }
        }
    }

    func pureUpload(api: API, options: UploadRequestOption) -> Observable<DataResponse<Data>> {
        .create {
            subscribe in
            var uploadRequest: UploadRequest!
            let acceptableStatusCodes: [Int]
            if api.acceptableStatusCodes.isEmpty {
                acceptableStatusCodes = self.acceptableStatusCodes
            } else {
                acceptableStatusCodes = api.acceptableStatusCodes
            }
            do {
                switch options.type {
                case .data(let data):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(data, with: request).validate(statusCode: acceptableStatusCodes)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .fileURL(let url):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(url, with: request).validate(statusCode: acceptableStatusCodes)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .stream(let stream):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(stream, with: request).validate(statusCode: acceptableStatusCodes)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .multipart(let fileUploads, let key):
                    self.sessionManager.upload(multipartFormData: {
                        multipartFormData in
                        for fileUpload in fileUploads {
                            if let data = fileUpload.data {
                                multipartFormData.append(data, withName: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            } else if let inputStream = fileUpload.inputStream {
                                multipartFormData.append(inputStream, withLength: fileUpload.size, name: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            } else if let fileUrl = fileUpload.fileUrl {
                                multipartFormData.append(fileUrl, withName: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            }
                        }
                        if let params = options.parameters {
                            for (key, value) in params {
                                if let data = String(describing: value).data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                    }, to: "\(self.environment.config.defaultServerUrl)\(api.endPoint)") {
                        encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            uploadRequest = upload.validate(statusCode: acceptableStatusCodes)
                            self.watchUploadRequest(upload, options: options, subscribe: subscribe)
                        case .failure(let error):
                            #if !RELEASE && !PRODUCTION
                            Swift.print("Response error", error as NSError)
                            #endif
                            subscribe.onError(error)
                        }
                    }
                }
            } catch {
                #if !RELEASE && !PRODUCTION
                Swift.print("Response error", error as NSError)
                #endif
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak uploadRequest] in
                uploadRequest?.cancel()
            }
        }
    }

    /// Download request
    /// Return an observable of raw DownloadResponse to keep data stable
    func pureDownload(api: API, options: DownloadRequestOption?) -> Observable<DownloadResponse<Data>> {
        .create {
            subscribe in
            var downloadRequest: DownloadRequest!
            let acceptableStatusCodes: [Int]
            if api.acceptableStatusCodes.isEmpty {
                acceptableStatusCodes = self.acceptableStatusCodes
            } else {
                acceptableStatusCodes = api.acceptableStatusCodes
            }
            do {
                let request = try self.makeRequest(api: api, options: options)
                downloadRequest = self.sessionManager.download(request, to: options?.downloadFileDestination?.make).validate(statusCode: acceptableStatusCodes)
                if let tracking = options?.tracking {
                    downloadRequest.downloadProgress(queue: tracking.queue, closure: tracking.handle)
                }
                downloadRequest.responseData {
                    response in
                    #if !RELEASE && !PRODUCTION
                    Swift.print(response)
                    if let data = response.value {
                        printDebug(data: data)
                    }
                    #endif
                    if let error = response.error {
                        return subscribe.onError(error)
                    }
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                }
            } catch {
                #if !RELEASE && !PRODUCTION
                Swift.print("Response error", error as NSError)
                #endif
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak downloadRequest] in
                downloadRequest?.cancel()
            }
        }
    }
}

private extension PureHTTPRequest {
    func watchUploadRequest(_ request: UploadRequest, options: UploadRequestOption, subscribe: AnyObserver<DataResponse<Data>>) {
        if let tracking = options.tracking {
            request.uploadProgress(queue: tracking.queue, closure: tracking.handle)
        }
        request.responseData {
            response in
            #if !RELEASE && !PRODUCTION
            Swift.print(response)
            if let data = response.data {
                printDebug(data: data)
            }
            #endif
            if let error = response.error {
                return subscribe.onError(error)
            }
            subscribe.onNext(response)
            subscribe.onCompleted()
        }
    }
}

#if !RELEASE && !PRODUCTION
private func printDebug(data: Data) {
    do {
        let serialization = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        switch serialization {
        case let dict as [String: Any]:
            Swift.print("Response represents", dict)
        case let array as Array<Any>:
            Swift.print("Response represents", array)
        default:
            Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
        }
    } catch {
        Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
    }
}
#endif

public extension PureHTTPRequest where Self: HTTPResponseTransformable {
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

public extension PureHTTPRequest where API: HTTPResponseTransformable {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    func execute(api: API, options: RequestOption?) -> Observable<API.Response>{
        pureExecute(api: api, options: options).map(api.transform)
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    func upload(api: API, options: UploadRequestOption) -> Observable<API.Response> {
        pureUpload(api: api, options: options).map(api.transform)
    }
}
