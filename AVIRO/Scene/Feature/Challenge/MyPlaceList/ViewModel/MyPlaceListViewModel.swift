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
        let whenViewDidLoadTrigger: Driver<Void>
        let selectedPlaceIndex: Driver<Int>
    }
     
    struct Output {
        let hasPlaces: Driver<Bool>
        let placesData: Driver<[MyPlaceCellModel]>
        let placesLoadError: Driver<APIError>
        let numberOfPlaces: Driver<Int>
        let selectedPlace: Driver<String>
    }
    
    func transform(with input: Input) -> Output {
        let places = BehaviorRelay<[MyPlaceCellModel]>(value: [])
        let placesLoadError = PublishSubject<APIError>()
        
        let hasPlaces = input.whenViewDidLoadTrigger
            .flatMapLatest { [weak self] _ -> Driver<[MyPlaceCellModel]> in
                guard let self = self else { return Driver.just([]) }
                
                return self.loadMyPlaceList(userId: MyData.my.id)
                    .do(onSuccess: { currentPlaces in
                        places.accept(currentPlaces)
                    })
                    .asDriver { _ in
                        placesLoadError.onNext(APIError.badRequest)
                        return Driver.empty()
                    }
            }
            .map { $0.count > 0 ? true : false }
            .asDriver()
        
        let numberOfPlaces = places
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let selectedPlace = input.selectedPlaceIndex
            .map { [weak self] index in
                guard let self = self else { return "" }
                var result = ""
                
                if places.value.indices.contains(index) {
                    result = places.value[index].placeId
                }
                
                return result
            }
            .asDriver()
                
        let placesDriver = places.asDriver()
        let onErrorEventDriver = placesLoadError.asDriver(onErrorJustReturn: .badRequest)
        
        return Output(
            hasPlaces: hasPlaces,
            placesData: placesDriver,
            placesLoadError: onErrorEventDriver,
            numberOfPlaces: numberOfPlaces,
            selectedPlace: selectedPlace
        )
    }
    
    private func loadMyPlaceList(
        userId: String
    ) -> Single<[MyPlaceCellModel]> {
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
