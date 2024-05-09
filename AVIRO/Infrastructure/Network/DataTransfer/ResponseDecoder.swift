//
//  ResponseDecoder.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

final class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    init() { }
    
    func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

final class RawDataResponseDecoder: ResponseDecoder {
    
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
