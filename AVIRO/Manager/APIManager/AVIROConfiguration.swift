//
//  AVIROConfiguration.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import Foundation

final class AVIROConfiguration {
    static var host: String = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let host = dict["AVIRO_Host"] as? String else {
            return ""
        }
        return host
    }()
    
    static var apikey: String = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let host = dict["AVIRO_Key"] as? String else {
            return ""
        }
        return host
    }()
}
