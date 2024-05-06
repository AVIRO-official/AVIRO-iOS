//
//  Endpoint.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

enum HTTPMethodType: String {
    case get    = "GET"
    case head   = "HEAD"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

protocol ResponseRequestable: RequestTable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}


final class EndPoint<R>: ResponseRequestable {
    typealias Response = <#type#>
    
    var responseDecoder: any ResponseDecoder
    
    var path: String
    
    var isFullPath: Bool
    
    var method: HTTPMethodType
    
    var headerParameters: [String : String]
    
    var queryParametersEncodable: (any Encodable)?
    
    var queryParameters: [String : Any]
    
    var bodyParametersEncodable: (any Encodable)?
    
    var bodyParameters: [String : Any]
    
    var bodyEncoder: any BodyEncoder
    
    
}
