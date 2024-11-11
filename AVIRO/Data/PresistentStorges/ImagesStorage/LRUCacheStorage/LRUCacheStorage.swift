//
//  LRUCacheStorage.swift
//  AVIRO
//
//  Created by 전성훈 on 11/11/24.
//

import Foundation

final class LRUCacheStorage: ImagesStorageInterface {
    
    private struct CacheNode {
        let key: String
        var value: Data
    }
    
    private(set) var capacity: UInt
    
    
    func getData(key: String, completion: @escaping (Data?) -> Void) {
        
    }
    
    func setData(key: String, value: Data) {
        
    }
}
