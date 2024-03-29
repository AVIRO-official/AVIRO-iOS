//
//  BookmarkManager.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/23.
//

import Foundation

protocol BookmarkFacadeProtocol {
    func fetchAllData(completionHandler: @escaping ((String) -> Void))
    func loadAllData() -> [String]
    func checkData(with placeId: String) -> Bool
    func updateData(with placeId: [String], completionHandler: @escaping ((String) -> Void))
    func deleteData(with placeId: [String], completionHandler: @escaping ((String) -> Void))
    func deleteAllData()
}

final class BookmarkFacadeManager: BookmarkFacadeProtocol {
    private let bookmarkArray: BookmarkDataProtocol
        
    init(bookmarkArray: BookmarkDataProtocol = BookmarkCache.shared) {
        self.bookmarkArray = bookmarkArray
    }
    
    func fetchAllData(completionHandler: @escaping ((String) -> Void)) {
        AVIROAPI.manager.loadBookmarkModels(with: MyData.my.id) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    guard let bookmarkData = success.data else {
                        if let errorMessage = success.message {
                            completionHandler(errorMessage)
                            return
                        }
                        
                        if let error = APIError.badRequest.errorDescription {
                            completionHandler(error)
                        }
                        
                        return
                    }
                    self?.bookmarkArray.updateAllData(with: bookmarkData.bookmarks)
                } else {
                    if let error = APIError.badRequest.errorDescription {
                        completionHandler(error)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    completionHandler(error)
                }
            }
        }
    }
    
    func loadAllData() -> [String] {
        bookmarkArray.loadAllData()
    }
    
    func checkData(with placeId: String) -> Bool {
        bookmarkArray.checkData(with: placeId)
    }
    
    func updateData(
        with placeId: [String],
        completionHandler: @escaping ((String) -> Void)
    ) {
        self.bookmarkArray.updateData(with: placeId) { [weak self] in
            self?.updateBookmark(
                completionHandler: completionHandler
            )
        }
    }
    
    func deleteData(
        with placeId: [String],
        completionHandler: @escaping ((String) -> Void)
    ) {
        self.bookmarkArray.deleteData(with: placeId) { [weak self] in
            self?.updateBookmark(
                completionHandler: completionHandler
            )
        }
    }
    
    private func updateBookmark(completionHandler: @escaping ((String) -> Void)) {
        let bookmarks = bookmarkArray.loadAllData()
        
        let postModel = AVIROUpdateBookmarkDTO(
            placeList: bookmarks,
            userId: MyData.my.id
        )
                
        AVIROAPI.manager.overwriteBookmarks(with: postModel) { result in
            switch result {
            case .success(let success):
                if success.statusCode != 200 {
                    if let message = success.message {
                        completionHandler(message)
                    } else {
                        completionHandler("에러 발생")
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    completionHandler(error)
                }
            }
        }
    }

    func deleteAllData() {
        bookmarkArray.deleteAllBookmark()
    }
}
