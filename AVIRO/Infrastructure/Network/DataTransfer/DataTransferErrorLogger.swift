//
//  DataTransferErrorLogger.swift
//  AVIRO
//
//  Created by 전성훈 on 5/9/24.
//

import Foundation

protocol DataTransferErrorLoggerProtocol {
    func log(error: Error)
}

final class DataTransferErrorLogger: DataTransferErrorLoggerProtocol {
    func log(error: Error) {
        printIfDebug("------------")
        printIfDebug("\(error)")
    }
}
