//
//  DIContainer.swift
//  AVIRO
//
//  Created by 전성훈 on 5/10/24.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    
    private var dependencies: [String: AnyObject] = [:]
    
    private init() { }
    
    func register<T: AnyObject>(_ type: T.Type, dependency: T) {
        let key = String(describing: type)
        
        dependencies[key] = dependency
    }
    
    func resolve<T: AnyObject>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        guard let value = dependencies[key] as? T else {
            printIfDebug("---- 의존성 key 값을 찾지 못했습니다 \(key) ----")
            
            return nil
        }
        
        return value
    }
}
