//
//  BodyEncoder.swift
//  AVIRO
//
//  Created by 전성훈 on 5/6/24.
//

import Foundation

protocol BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data?
}

struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String : Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

struct AsciiBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String : Any]) -> Data? {
        return parameters.queryString
            .data(
                using: String.Encoding.ascii,
                allowLossyConversion: true
            )
    }
}

private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}
