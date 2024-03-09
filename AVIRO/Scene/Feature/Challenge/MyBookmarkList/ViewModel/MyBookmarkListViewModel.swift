//
//  MyBookmarkListViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

import RxSwift
import RxCocoa

// TODO: - Bookmark list가 하나라도 바뀐게 있다면 viewDisAppear할 때 바뀐것만 bookmark update api 호출 (bookmark Manager 활용)

final class MyBookmarkListViewModel: ViewModel {
    
    struct Input {
        let whenViewDidLoad: Driver<Void>
        let whenBookmarkChangedState: Driver<Int>
    }
     
    struct Output {
        let whenLoadBookmarks: Driver<Bool>
        let loadBookmarks: Driver<[MyBookmarkCellModel]>
        let onErrorEvent: Driver<APIError>
        let numberOfBookmarks: Driver<Int>
        let whenUpdateBookmarks: Driver<Void>
    }
    
    func transform(with input: Input) -> Output {
        let bookmarks = BehaviorRelay<[MyBookmarkCellModel]>(value: [])

        let bookmarkLoadError = PublishSubject<APIError>()
        
        let whenLoadBookmarks = input.whenViewDidLoad
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
        
        let numberOfBookmarks = bookmarks
            .map { $0.filter { $0.isStar } }
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let updatedBookmarks = input.whenBookmarkChangedState
             .do(onNext: { index in
                 var currentBookmarks = bookmarks.value
                 if currentBookmarks.indices.contains(index) {
                     currentBookmarks[index].isStar.toggle()
                     bookmarks.accept(currentBookmarks)
                 }
             })
             .map { _ in }
             .asDriver(onErrorDriveWith: .empty())
        
        let bookmarksDriver = bookmarks.asDriver()
        let onErrorEventDriver = bookmarkLoadError.asDriver(onErrorJustReturn: .badRequest)
        
        return Output(
            whenLoadBookmarks: whenLoadBookmarks,
            loadBookmarks: bookmarksDriver,
            onErrorEvent: onErrorEventDriver,
            numberOfBookmarks: numberOfBookmarks,
            whenUpdateBookmarks: updatedBookmarks
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
