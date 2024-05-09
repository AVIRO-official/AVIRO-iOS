//
//  NetworkErrorLogger.swift
//  AVIRO
//
//  Created by 전성훈 on 5/9/24.
//

import Foundation

protocol NetworkErrorLoggerProtocol {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

final class NetworkErrorLogger: NetworkErrorLoggerProtocol {
    func log(request: URLRequest) {
        print("--------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody,
           let result =  ((try? JSONSerialization.jsonObject(
            with: httpBody,
            options: []
           ) as? [String: AnyObject]
        ) as [String: AnyObject]??) {
            printIfDebug("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody,
                  let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(String(describing: resultString))")
        }
        print("--------")
    }
    
    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        
        print("--------")

        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("responseData: \(String(describing: dataDict))")
        }
        print("--------")
    }
    
    func log(error: Error) {
        print("--------")
        printIfDebug("\(error)")
        print("--------")
    }
}

private func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
