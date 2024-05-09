//
//  DataTransferError.swift
//  AVIRO
//
//  Created by 전성훈 on 5/9/24.
//

import Foundation

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolveNetworkFailure(Error)
}
