//
//  NetworkManager.swift
//  JPMorganChase Take-Home Assessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import OSLog
import Combine

/// This protocol describes the functionality of requesting some data from an endpoint
protocol MakesNetworkRequests {
    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

/// The types of network erros that can be returned in the result of a network request
enum NetworkError: LocalizedError {
    /// The user is not connected to the network
    case networkIsNotReachable
    
    /// Invalid request, e.g. invalid URL
    case invalidRequestError(String)
    
    /// Indicates an error on the transport layer, e.g. not being able to connect to the server
    case transportError(Error)
    
    /// Received an invalid response, e.g. non-HTTP result
    case invalidResponse
    
    /// The server sent data in an unexpected format
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkIsNotReachable:
            return "Oh no! it seems you're not connected to the network. Check your wifi/cellular connection"
        case .invalidRequestError(let message):
            return "Invalid request: \(message)"
        case .transportError(let error):
            return "Transport error: \(error)"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        }
    }
}

final class NetworkManager: MakesNetworkRequests {
    static let shared = NetworkManager()
    
    /// Making init private so that the shared instance is the only instance of this class that can be instantiated
    private init() {}
    
    // MARK: - MakesNetworkRequests protocol Implementation
    /// Makes a network request to an endpoint depending on the specification of the endpoint itself
    /// The method will also check for whether the network is reachable and if it's not will return a reachability error before even trying to make the request. So there are no performance issues here
    /// Otherwise if the network is reachable will make the request and return a result object with the data/error
    /// - Parameter endpoint: the endpoint to make the request to
    /// - Returns: a result object with the data or an error
    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        let components = buildURL(endpoint: endpoint)
        
        guard NetworkMonitor.shared.isReachable else {
            Logger.networking.error("Network Request to \(components.path) failed: Network Unreachable")
            return Fail(error: NetworkError.networkIsNotReachable).eraseToAnyPublisher()
        }
        
        guard let url = components.url else {
            let errorMessage = "Building URL with scheme \(components.scheme ?? "") host \(components.host ?? "") path \(components.path) Failed"
            Logger.networking.error("\(errorMessage)")
            return Fail(error: NetworkError.invalidRequestError(errorMessage)).eraseToAnyPublisher()
        }
        
        Logger.networking.info("url \(url)")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        for (key, value) in endpoint.headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        Logger.networking.info("urlRequest \(urlRequest)")
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .mapError { error -> Error in
                // Most likely couldn't connect to the server for any reason
                Logger.networking.info("Received error from server, \(error)")
                return NetworkError.transportError(error)
            }
            // handle all other errors
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                Logger.networking.info("Received response from server, now checking status code")
                
                guard let urlResponse = response as? HTTPURLResponse else {
                    Logger.networking.error("urlRequest \(urlRequest) failed with Invalid Response Error")
                    throw NetworkError.invalidResponse
                }
                
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    let decoder = JSONDecoder()
                    let apiError = try decoder.decode(T.self,
                                                      from: data)
                    
                    if urlResponse.statusCode == 400 {
                        Logger.networking.error("urlRequest \(urlRequest) failed with Invalid Request Error. Received 400 from server")
                        throw NetworkError.invalidRequestError("\(apiError)")
                    }
                }
                return (data, response)
            }
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError {
                if let error = $0 as? NetworkError {
                    return error
                } else {
                    Logger.networking.error("urlRequest \(urlRequest) failed to decode with error: \($0)")
                    return NetworkError.decodingError($0)
                }
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    /// Helper method to construct a `URLComponents` object from an endpoint
    /// - Parameter endpoint: the endpoint in question
    /// - Returns: a `URLComponents` object which can later be converted to a `URL`
    private func buildURL(endpoint: Endpoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = endpoint.scheme.rawValue
        components.host = endpoint.baseURL
        components.path = endpoint.path
        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters
        }
        return components
    }
}
