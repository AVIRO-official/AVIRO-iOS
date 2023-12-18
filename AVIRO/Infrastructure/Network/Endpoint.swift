//
//  Endpoint.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import Foundation

enum HTTPMethodType: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

final class Endpoint<R>: ResponseRequestable {
    typealias Response = R
    
    let path: String
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyEncoder: BodyEncoder
    
    let responseDecoder: ResponseDecoder
    
    init(
        path: String,
        method: HTTPMethodType,
        headerParameters: [String: String] = [:],
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String: Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyEncoder: BodyEncoder = JSONBodyEncoder(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder()
    ) {
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}

protocol ResponseRequestable: RequestTable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

protocol RequestTable {
    var path: String { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyEncoder: BodyEncoder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

extension RequestTable {
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest {
        let url = try self.url(with: networkConfig)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = networkConfig.headers
        
        headerParameters.forEach {
            allHeaders.updateValue($1, forKey: $0)
        }
        
        // TODO: Encoding 방식 수정 필요
        if let bodyParametersEncodable = bodyParametersEncodable {
            let encodeBody = bodyEncoder.encode(bodyParametersEncodable)
            urlRequest.httpBody = encodeBody
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
    
    private func url(with networkConfig: NetworkConfigurable) throws -> URL {
        let baseURL = networkConfig.baseURL.absoluteString.last != "/" ?
        networkConfig.baseURL.absoluteString + "/" :
        networkConfig.baseURL.absoluteString
        
        let endpoint = baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw RequestGenerationError.components
        }
        
        var urlQueryItems: [URLQueryItem] = []
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters

        networkConfig.queryParameters.forEach {
            urlQueryItems.append(
                URLQueryItem(
                    name: $0.key,
                    value: $0.value
                )
            )
        }
        
        queryParameters.forEach {
            urlQueryItems.append(
                URLQueryItem(
                    name: $0.key,
                    value: "\($0.value)"
                )
            )
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        
        return url
    }
}

protocol BodyEncoder {
    func encode(_ parameters: Encodable) -> Data?
}

struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: Encodable) -> Data? {
        return try? JSONEncoder().encode(parameters)
    }
}

enum RequestGenerationError: Error {
    case components
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        
        return jsonData as? [String: Any]
    }
}
