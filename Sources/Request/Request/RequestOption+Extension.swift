//
//  RequestOption+Extension.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

public extension ProgressTrackable {
    var queue: DispatchQueue {
        return .main
    }
}

public extension TrackingOption where Self: ProgressTrackable {
    var tracking: ProgressTrackable? {
        return self
    }
}

public extension DownloadRequestOption where Self: DownloadFileDestination {
    var downloadFileDestination: DownloadFileDestination? {
        return self
    }
}
