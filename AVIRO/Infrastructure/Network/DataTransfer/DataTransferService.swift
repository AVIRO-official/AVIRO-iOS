//
//  DataTransferService.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

protocol DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void)
}

extension DispatchQueue: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}

protocol DataTransferServiceProtocol {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
}

protocol DataTransferErrorResolverProtocol {
    func resolve(error: NetworkError) -> Error
}

final class DataTransferService {
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolverProtocol
    private let errorLogger: DataTransferErrorLoggerProtocol
    
    init(
        networkService: NetworkService,
        errorResolver: DataTransferErrorResolverProtocol,
        errorLogger: DataTransferErrorLoggerProtocol
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DataTransferService: DataTransferServiceProtocol {
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        on queue: any DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where T == E.Response {
        networkService.request(endPoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(
                    data: data,
                    decoder: endpoint.responseDecoder
                )
                
                queue.asyncExecute {
                    completion(result)
                }
                
            case .failure(let error):
                self.errorLogger.log(error: error)
                
                let error = self.resolve(networkError: error)
                
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where T == E.Response {
        request(
            with: endpoint,
            on: DispatchQueue.main,
            completion: completion
        )
    }
    
    func request<E: ResponseRequestable>(
        with endpoint: E,
        on queue: any DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void {
        networkService.request(endPoint: endpoint) { result in
            switch result {
            case .success:
                queue.asyncExecute {
                    completion(.success(()))
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void {
        request(with: endpoint, on: DispatchQueue.main, completion: completion)
    }
    
    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            
            let result: T = try decoder.decode(data)
            
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(
        networkError error: NetworkError
    ) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        
        return resolvedError is NetworkError ?
            .networkFailure(error) : .resolveNetworkFailure(resolvedError)
    }
}

final class DataTransferErrorResolver: DataTransferErrorResolverProtocol {
    func resolve(error: NetworkError) -> any Error {
        return error
    }
}
