//
//  NetworkSessionManager.swift
//  AVIRO
//
//  Created by 전성훈 on 5/9/24.
//

import Foundation

protocol NetworkSessionManagerProtocol {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable
}

final class NetworkSessionManager: NetworkSessionManagerProtocol {
    func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(
            with: request,
            completionHandler: completion
        )
        task.resume()
        
        return task
    }
}

