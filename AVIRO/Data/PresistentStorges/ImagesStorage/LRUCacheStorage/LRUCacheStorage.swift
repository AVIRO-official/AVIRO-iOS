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
    private var dict = [String: Node<CacheNode>]()
    private var list = DoublyLinkedList<CacheNode>()
    
    init(capacity: UInt = 50) {
        self.capacity = capacity
    }
    
    func getData(
        key: String,
        completion: @escaping (Data?) -> Void
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            guard let node = self.dict[key] else {
                completion(nil)
                return
            }
            
            self.list.moveToHead(node: node)
            
            completion(node.value.value)
        }
    }
    
    func setData(
        key: String,
        value: Data
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            if let node = self.dict[key] {
                self.list.moveToHead(node: node)
                node.value.value = value
            } else {
                if self.list.count == self.capacity {
                    if let node = self.list.removeLast() {
                        self.dict.removeValue(forKey: node.value.key)
                    }
                }
                
                let newNode = self.list.push(value: CacheNode(key: key, value: value))
                self.dict[key] = newNode
            }
        }
    }
}
