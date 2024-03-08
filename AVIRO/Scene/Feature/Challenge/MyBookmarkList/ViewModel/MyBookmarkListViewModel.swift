//
//  MyBookmarkListViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

import RxSwift
import RxCocoa

final class MyBookmarkListViewModel: ViewModel {
    struct Input {
        let whenViewWillAppear: Driver<Void>
    }
     
    struct Output {
        let myBookmarkList: Driver<[MyBookmarkCellModel]>
        let numberOfBookmarks: Driver<Int>
    }
    
    func transform(with input: Input) -> Output {
        let myBookmarkListError = PublishSubject<APIError>()
        
        let myBookmarkListResult = input.whenViewWillAppear
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<[MyBookmarkCellModel]>.empty()
                }
                
                return self.loadMyBookmarkList(userId: MyData.my.id)
                    .asDriver { _ in
                        myBookmarkListError.onNext(APIError.badRequest)
                        return Driver.empty()
                    }
            }
        
        let numberOfBookmarks = myBookmarkListResult
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            myBookmarkList: myBookmarkListResult,
            numberOfBookmarks: numberOfBookmarks
        )
    }
    
    private func loadMyBookmarkList(userId: String) -> Single<[MyBookmarkCellModel]> {
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
