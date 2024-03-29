//
//  BookmarkSingletion.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/23.
//

import Foundation

protocol BookmarkDataProtocol {
    func updateAllData(with list: [String])
    func loadAllData() -> [String]
    func checkData(with placeId: String) -> Bool
    func updateData(with placeIds: [String], compeltionHandler: @escaping (() -> Void))
    func deleteData(with placeIds: [String], compeltionHandler: @escaping (() -> Void))
    func deleteAllBookmark()
}

final class BookmarkCache: BookmarkDataProtocol {
    static let shared = BookmarkCache()
    
    private var bookmarkList: [String] = []
    
    private init() { }
    
    func updateAllData(with list: [String]) {
        self.bookmarkList = list
    }
    
    func loadAllData() -> [String] {
        bookmarkList
    }
    
    func checkData(with placeId: String) -> Bool {
        bookmarkList.contains(placeId)
    }
    
    func updateData(with placeIds: [String], compeltionHandler: @escaping (() -> Void)) {
        placeIds.forEach { placeId in
            if !bookmarkList.contains(placeId) {
                bookmarkList.append(placeId)
            }
        }
        
        compeltionHandler()
    }
    
    func deleteData(with placeIds: [String], compeltionHandler: @escaping (() -> Void)) {
        placeIds.forEach { placeId in
            if let index = bookmarkList.firstIndex(of: placeId) {
                bookmarkList.remove(at: index)
            }
        }
        
        compeltionHandler()
    }
    
    func deleteAllBookmark() {
        bookmarkList.removeAll()
    }
}
