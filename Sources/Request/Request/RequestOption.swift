//
//  RequestOption.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 4/8/19.
//

import RxCoreBase
import Alamofire
import RxSwift

public protocol ProgressTrackable {
    var queue: DispatchQueue { get }
    func handle(progress: Progress)
}

public protocol TrackingOption {
    var tracking: ProgressTrackable? { get }
}

public protocol DownloadFileDestination {
    func make(temporaryURL: URL, of response: HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions)
}

public protocol DownloadRequestOption: RequestOption, TrackingOption {
    var downloadFileDestination: DownloadFileDestination? { get }
}

public protocol FileUpload {
    var fileUrl: URL? { get }
    var mimeType: String { get }
    var data: Data? { get }
    var fileName: String { get }
    var inputStream: InputStream? { get }
    var size: UInt64 { get }
}

public enum UploadRequestOptionType {
    case data(_ data: Data)
    case fileURL(_ url: URL)
    case stream(_ input: InputStream)
    case multipart(_ fileUploads: [FileUpload], key: String)
}

public protocol UploadRequestOption: RequestOption, TrackingOption {
    var type: UploadRequestOptionType { get }
}
