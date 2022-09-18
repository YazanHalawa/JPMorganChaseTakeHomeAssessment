//
//  NYCOpenData.swift
//  JPMorganChase Take-Home Assessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation

enum NYCOpenData: Endpoint {
    case schools
    case satScores
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var scheme: HTTPScheme {
        return .https
    }
    
    var headers: [String : String] {
        // For simplicity's sake I put the token here but usually I'd save this in keychain as it is more secure (although can be found out if the device got jailbroken)
        // More realistically for a real app authentication should be done with OAuth 2.0 or some similar method
        return ["X-App-Token": "fSScLfXLezDiI18tWmgwBqo8K"]
    }
    
    var baseURL: String {
        return "data.cityofnewyork.us"
    }
    
    var path: String {
        switch self {
        case .schools:
            return "/resource/s3k6-pzi2.json"
        case .satScores:
            return "/resource/f9bf-2cp4.json"
        }
    }
    
    var queryParameters: [URLQueryItem] {
        return []
    }
}
