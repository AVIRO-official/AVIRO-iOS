//
//  MyPlaceListViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

import RxSwift
import RxCocoa

final class MyPlaceListViewModel: ViewModel {
    struct Input {
        let whenViewWillAppear: Driver<Void>
    }
     
    struct Output {
        let myPlaceList: Driver<[MyPlaceCellModel]>
        let numberOfPlaces: Driver<Int>
    }
    
    func transform(with input: Input) -> Output {
        let myPlaceListError = PublishSubject<Error>()
        
        let myPlaceListResult = input.whenViewWillAppear
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<[MyPlaceCellModel]>.empty()
                }
                
                return self.loadMyPlaceList(userId: MyData.my.id)
                    .asDriver { error in
                        myPlaceListError.onNext(error)
                        return Driver.empty()
                    }
            }
        
        let numberOfPlaces = myPlaceListResult
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)

                
        return Output(myPlaceList: myPlaceListResult, numberOfPlaces: numberOfPlaces)
    }
    
    private func loadMyPlaceList(userId: String) -> Single<[MyPlaceCellModel]> {
        return Single.create { single in
            AVIROAPI.manager.loadMyPlaceList(with: userId) { result in
                switch result {
                case .success(let data):
                    var model: [MyPlaceCellModel] = []
                    
                    guard data.statusCode == 200 else {
                        return single(.failure(APIError.badRequest))
                    }
                    
                    if let placeList = data.data?.placeList {
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
}
