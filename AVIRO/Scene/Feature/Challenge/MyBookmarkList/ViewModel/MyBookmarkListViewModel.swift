//
//  MyBookmarkListViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

import RxSwift
import RxCocoa

// TODO: - Bookmark list가 하나라도 바뀐게 있다면 viewWillDisappear할 때 바뀐것만 bookmark update api 호출 (bookmark Manager 활용)

final class MyBookmarkListViewModel: ViewModel {
    
    private weak var challengeViewModelProtocol: ChallengeViewModelFromChildProtocol!
    private let bookmarkManager: BookmarkFacadeProtocol!
    
    private var cancelledBookmarkList: [String] = []
    private var onSelectedBookmark: Bool = false
    
    struct Input {
        let viewDidLoadTrigger: Driver<Void>
        let viewWillDisAppearTrigger: Driver<Void>
        let bookmarkStateChangeIndex: Driver<Int>
        let selectedBookmarkIndex: Driver<Int>
    }
    
    struct Output {
        let hasBookmarks: Driver<Bool>
        let bookmarksData: Driver<[MyBookmarkCellModel]>
        let bookmarkLoadError: Driver<APIError>
        let countOfStarredBookmarks: Driver<Int>
        let bookmarkUpdateComplete: Driver<Void>
        let selectedBookmark: Driver<String>
        let deletedBookmarks: Driver<Void>
    }
    
    init(
        challengeViewModelProtocol: ChallengeViewModelFromChildProtocol,
        bookmarkManager: BookmarkFacadeManager
    ) {
        self.challengeViewModelProtocol = challengeViewModelProtocol
        self.bookmarkManager = bookmarkManager
    }
    
    func transform(with input: Input) -> Output {
        let bookmarks = BehaviorRelay<[MyBookmarkCellModel]>(value: [])
        
        let bookmarkLoadError = PublishSubject<APIError>()
        
        let hasBookmarks = input.viewDidLoadTrigger
            .flatMapLatest { [weak self] _ -> Driver<[MyBookmarkCellModel]> in
                guard let self = self else { return Driver.just([]) }
                
                return self.loadMyBookmarkList(userId: MyData.my.id)
                    .do(onSuccess: { currentBookmarks in
                        bookmarks.accept(currentBookmarks)
                    })
                    .asDriver { _ in
                        bookmarkLoadError.onNext(APIError.badRequest)
                        return Driver.empty()
                    }
            }
            .map { $0.count > 0 ? true : false }
            .asDriver()
        
        let countOfStarredBookmarks = bookmarks
            .map { $0.filter { $0.isStar } }
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let bookmarkUpdateComplete = input.bookmarkStateChangeIndex
            .do(onNext: { [weak self] index in
                guard let self = self else { return }
                var currentBookmarks = bookmarks.value
                if currentBookmarks.indices.contains(index) {
                    let placeId = currentBookmarks[index].placeId
                    
                    if let indexOfPlaceId = self.cancelledBookmarkList.firstIndex(of: placeId) {
                        self.cancelledBookmarkList.remove(at: indexOfPlaceId)
                    } else {
                        self.cancelledBookmarkList.append(placeId)
                    }
                    
                    currentBookmarks[index].isStar.toggle()
                    
                    bookmarks.accept(currentBookmarks)
                }
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        /// result가 "" 이면 index Error
        let selectedBookmark = input.selectedBookmarkIndex
            .map { [weak self] index in
                guard let self = self else { return "" }
                var result = ""
                
                if bookmarks.value.indices.contains(index) {
                    result = bookmarks.value[index].placeId
                    self.onSelectedBookmark = true
                }
                
                return result
            }
            .asDriver()
        
        let deletedBookmarks = input.viewWillDisAppearTrigger
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                if !self.cancelledBookmarkList.isEmpty {
                    challengeViewModelProtocol.fromChildView = self.onSelectedBookmark ? false : true 
                    self.bookmarkManager.deleteData(
                        with: self.cancelledBookmarkList,
                        completionHandler: { _ in }
                    )
                }
            })
            .asDriver()
        
        let bookmarksDriver = bookmarks.asDriver()
        let onErrorEventDriver = bookmarkLoadError.asDriver(onErrorJustReturn: .badRequest)
        
        return Output(
            hasBookmarks: hasBookmarks,
            bookmarksData: bookmarksDriver,
            bookmarkLoadError: onErrorEventDriver,
            countOfStarredBookmarks: countOfStarredBookmarks,
            bookmarkUpdateComplete: bookmarkUpdateComplete,
            selectedBookmark: selectedBookmark,
            deletedBookmarks: deletedBookmarks
        )
    }
    
    private func loadMyBookmarkList(
        userId: String
    ) -> Single<[MyBookmarkCellModel]> {
        return Single.create { single in
            AVIROAPI.manager.loadMyBookmarkList(with: userId) { result in
                switch result {
                case .success(let data):
                    var model: [MyBookmarkCellModel] = []
                    guard data.statusCode == 200 else {
                        return single(.failure(APIError.badRequest))
                    }
                    
                    if let bookmarkList = data.data?.placeList {
                        bookmarkList.forEach {
                            model.append($0.toDomain())
                        }
                    }
                    
                    single(.success(model))
                    
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
