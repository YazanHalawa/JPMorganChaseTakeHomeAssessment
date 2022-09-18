//
//  Endpoint.swift
//  JPMorganChase Take-Home Assessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation

/// Any endpoint needs to specify the following information. This allows us to house all logic to construct the URL request in the conforming entity. Then a separate entity can perform the actual logic of making the network request
protocol Endpoint {
    var httpMethod: HTTPMethod { get }
    var scheme: HTTPScheme { get }
    var baseURL: String { get }
    var path: String { get }
    var headers: [String: String] { get }
    var queryParameters: [URLQueryItem] { get }
}

enum HTTPMethod: String, Codable {
    case get =  "GET"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
    case put = "PUT"
}

enum HTTPScheme: String, Codable {
    case http, https
}
