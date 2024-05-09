//
//  NetworkService.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

protocol NetworkCancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }

protocol NetworkServiceProtocol {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(
        endPoint: RequestTable,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable?
}

final class NetworkService {
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManagerProtocol
    private let logger: NetworkErrorLoggerProtocol
    
    init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager = NetworkSessionManager(),
        logger: NetworkErrorLogger
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }
    
    private func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                
                completion(.success(data))
            }
        }
        
        logger.log(request: request)
        
        return sessionDataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension NetworkService: NetworkServiceProtocol {
    func request(
        endPoint: RequestTable,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable? {
        do {
            let urlRequest = try endPoint.urlRequest(with: config)
            
            return request(urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}
