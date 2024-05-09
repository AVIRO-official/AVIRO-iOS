//
//  RequestTable.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

enum RequestGenerationError: Error {
    case components
}

protocol RequestTable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoder: BodyEncoder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

extension RequestTable {
    func url(with config: NetworkConfigurable) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components
        }
        
        var urlQueryItmes = [URLQueryItem]()
        
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        
        config.queryParameters.forEach {
            urlQueryItmes.append(
                URLQueryItem(
                    name: $0.key,
                    value: $0.value
                )
            )
        }
        
        queryParameters.forEach {
            urlQueryItmes.append(
                URLQueryItem(
                    name: $0.key,
                    value: "\($0.value)"
                )
            )
        }
        
        urlComponents.queryItems = !urlQueryItmes.isEmpty ? urlQueryItmes : nil
        
        guard let url = urlComponents.url else { throw
            RequestGenerationError.components }
        
        return url
    }
    
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        
        headerParameters.forEach {
            allHeaders.updateValue($1, forKey: $0)
        }
        
        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        
        return jsonData as? [String: Any]
    }
}
