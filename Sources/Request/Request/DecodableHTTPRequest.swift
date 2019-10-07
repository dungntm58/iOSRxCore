//
//  File.swift
//  CoreRequest
//
//  Created by Robert on 7/21/19.
//

public protocol DecodableHTTPRequest: HTTPRequest where Response: Decodable {
    var decoder: JSONDecoder { get }
}
