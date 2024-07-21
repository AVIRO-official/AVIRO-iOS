//
//  TempError.swift
//  AVIRO
//
//  Created by 전성훈 on 7/22/24.
//

import Foundation

enum TempError: LocalizedError {
    case temp(String)
    
    var errorDescription: String? {
        switch self {
        case .temp(let message):
            return message
        }
    }
}
