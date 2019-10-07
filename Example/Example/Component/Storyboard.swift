//
//  Storyboard.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxCoreBaseExtension

enum AppStoryboard: String, Storyboard {
    case main = "Main"
    
    var name: String {
        return rawValue
    }
    
    var bundle: Bundle? {
        return nil
    }
}

extension Dictionary: RequestOption where Key == String {
    public var parameters: [String : Any]? {
        return self
    }
}
