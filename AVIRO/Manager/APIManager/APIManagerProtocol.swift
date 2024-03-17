//
//  APIManager.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/26.
//

import Foundation

protocol APIManagerProtocol {
    var session: URLSession { get }
    
    func performRequest<T: Decodable>(
        with url: URL,
        httpMethod: HTTPMethodType,
        requestBody: Data?,
        headers: [String: String]?,
        completionHandler: @escaping (Result<T, APIError>) -> Void
    )
}

extension APIManagerProtocol {
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
//        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }
}
