//
//  MyCommentListViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

import RxSwift
import RxCocoa

final class MyCommentListViewModel: ViewModel {
    struct Input {
        let viewDidLoadTrigger: Driver<Void>
        let selectedReviewIndex: Driver<Int>
        let deletedReviewIndex: Driver<Int>
    }
     
    struct Output {
        let hasReviews: Driver<Bool>
        let reviewsData: Driver<[MyCommentCellModel]>
        let reviewsLoadError: Driver<APIError>
        let numberOfReviews: Driver<Int>
        let selectedReview: Driver<String>
        let deletedReview: Driver<String>
    }
    
    func transform(with input: Input) -> Output {
        let reviews = BehaviorRelay<[MyCommentCellModel]>(value: [])
        let reviewsLoadError = PublishSubject<APIError>()
        
        let hasReviews = input.viewDidLoadTrigger
            .flatMapLatest { [weak self] _ -> Driver<[MyCommentCellModel]> in
                guard let self = self else { return Driver.just([]) }
                
                return self.loadMyReviews(userId: MyData.my.id)
                    .do(onSuccess: { currentReviews in
                        reviews.accept(currentReviews)
                    })
                    .asDriver { _ in
                        reviewsLoadError.onNext(APIError.badRequest)
                        return Driver.empty()
                    }
            }
            .map { $0.count > 0 ? true : false }
            .asDriver()
        
        let numberOfReviews = reviews
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let selectedReview = input.selectedReviewIndex
            .map { index in
                var result = ""
                
                if reviews.value.indices.contains(index) {
                    result = reviews.value[index].placeId
                }
                
                return result
            }
            .asDriver()
        
        let deletedReview = input.deletedReviewIndex
            .flatMapLatest { [weak self] index -> Driver<String> in
                guard let self = self, reviews.value.indices.contains(index) else {
                    return Driver.just("")
                }
                
                let reviewId = reviews.value[index].commentId
                
                return self.deleteMyReview(
                    userId: MyData.my.id,
                    reviewId: reviewId
                )
                .do(onSuccess: { (_, isSuccess) in
                    if isSuccess {
                        var updatedReviews = reviews.value
                        updatedReviews.remove(at: index)
                        reviews.accept(updatedReviews)
                    }
                })
                .map { return $0.0 }
                .asDriver { _ in
                    return Driver.empty()
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let reviewsDriver = reviews.asDriver()
        let onErrorEventDriver = reviewsLoadError.asDriver(onErrorJustReturn: .badRequest)
        
        return Output(
            hasReviews: hasReviews,
            reviewsData: reviewsDriver,
            reviewsLoadError: onErrorEventDriver,
            numberOfReviews: numberOfReviews,
            selectedReview: selectedReview,
            deletedReview: deletedReview
        )
    }
    
    private func loadMyReviews(userId: String) -> Single<[MyCommentCellModel]> {
        return Single.create { single in
            AVIROAPI.manager.loadMyCommentList(with: userId) { response in
                switch response {
                case .success(let data):
                    var model: [MyCommentCellModel] = []
                    
                    guard data.statusCode == 200 else {
                        return single(.failure(APIError.badRequest))
                    }
                    
                    if let placeList = data.data?.commentList {
                        placeList.forEach {
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
    
    private func deleteMyReview(
        userId: String,
        reviewId: String
    ) -> Single<(String, Bool)> {
        return Single.create { single in
            let deletedReview = AVIRODeleteReveiwDTO(
                commentId: reviewId,
                userId: userId
            )
            
            AVIROAPI.manager.deleteReview(with: deletedReview) { response in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let data):
                        if data.statusCode != 200 {
                            single(.success(("다시 시도해주세요.", false)))
                        } else {
                            single(.success(("후기가 삭제했습니다.", true)))
                        }
                    case .failure:
                        single(.success(("다시 시도해주세요.", false)))
                    }
                }
            }
            return Disposables.create()
        }
    }
}
