//
//  DoubleLinkedList.swift
//  AVIRO
//
//  Created by 전성훈 on 11/11/24.
//

import Foundation

final class Node<T> {
    var value: T
    var next: Node<T>?
    var prev: Node<T>?
    
    init(
        value: T,
        next: Node<T>? = nil,
        prev: Node<T>? = nil
    ) {
        self.value = value
        self.next = next
        self.prev = prev
    }
}

final class DoubleLinkedList<T> {
    private var head: Node<T>?
    private var tail: Node<T>?
    
    var count: Int = 0
    
    var isEmpty: Bool { head == nil }
    var first: Node<T>? { head }
    
    func node(at index: Int) -> Node<T>? {
        let center = count / 2
        
        if index <= center {
            var currentIndex = 0
            var currentNode = head
            
            while currentNode != nil && currentIndex < index {
                currentNode = currentNode!.next
                currentIndex += 1
            }
            
            return currentNode
        } else {
            var currentIndex = count - 1
            var currentNode = tail
            
            while currentNode != nil && currentIndex > index {
                currentNode = currentNode!.prev
                currentIndex -= 1
            }
            
            return currentNode
        }
    }
    
    @discardableResult
    func push(value: T) -> Node<T> {
        let newNode = Node(value: value)
        
        count += 1
        
        guard tail != nil else {
            head = newNode
            tail = newNode
            
            return newNode
        }
        
        
    }
}
