//
//  DataStore.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 2/15/19.
//

import CoreData
import RxCoreBase
import RxCoreRepository

public protocol CoreDataDataStore: DataStore {
    var configuration: CoreDataConfiguration { get }
}

public protocol CoreDataIdentifiableDataStore: CoreDataDataStore, IdentifiableDataStore {}
