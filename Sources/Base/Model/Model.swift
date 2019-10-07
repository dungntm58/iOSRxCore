//
//  Model.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol Identifiable {
    associatedtype IDType: Hashable

    var id: IDType { get }
}

public protocol Expirable {
    var ttl: TimeInterval { get }
    var localUpdatedDate: Date { get }
}

public extension Expirable {
    var expiryDate: Date? {
        if ttl > 0 {
            return localUpdatedDate.addingTimeInterval(ttl)
        }
        return nil
    }

    var isValid: Bool {
        return expiryDate == nil || expiryDate! <= Date()
    }
}
