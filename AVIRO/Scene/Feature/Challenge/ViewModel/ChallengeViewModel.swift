//
//  ChallengeViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import RxSwift
import RxCocoa

final class ChallengeViewModel: ViewModel {
    var challengeTitle: String = ""
    
    struct Input {
        let loadData: Driver<Void>
        let tappedChallengeInfoButton: Driver<Void>
        let tappedNavigationBarRightButton: Driver<Void>
    }
    
    struct Output {
        let myContributionCountResult: Driver<AVIROMyContributionCountDTO>
        let challengeInfoResult: Driver<AVIROChallengeInfoDTO>
        let myChallengeLevelResult: Driver<AVIROMyChallengeLevelResultDTO>
        
        let afterTappedChallengeInfoButton: Driver<Void>
        let afterTappedNavigationBarRightButton: Driver<Void>
        let error: Driver<APIError>
    }
    
    func transform(with input: Input) -> Output {
        let challengeInfoError = PublishSubject<Error>()
        let myContributionCountError = PublishSubject<Error>()
        let myChallengeLevelError = PublishSubject<Error>()
        
        let challengeInfoResult = input.loadData
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<AVIROChallengeInfoDTO>.empty()
                }
                
                return self.loadChallengeInfoAPI()
                    .asDriver(onErrorRecover: { error in
                        challengeInfoError.onNext(error)
                        return Driver.empty()
                    })
            }
        
        let myChallengeLevelResult = input.loadData
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<AVIROMyChallengeLevelResultDTO>.empty()
                }
                
                return self.loadMyChallengeLevelAPI(userId: MyData.my.id)
                    .asDriver(onErrorRecover: { error in
                        myChallengeLevelError.onNext(error)
                        return Driver.empty()
                    })
            }
        
        let myContributionCountResult = input.loadData
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<AVIROMyContributionCountDTO>.empty()
                }
                
                return self.loadMyContributedCountAPI(userId: MyData.my.id)
                    .asDriver(onErrorRecover: { error in
                        myContributionCountError.onNext(error)
                        return Driver.empty()
                    })  
            }
        
        let combinedError = Observable.merge(challengeInfoError, myContributionCountError, myChallengeLevelError)
            .map { error -> APIError in
                return (error as? APIError) ?? APIError.badRequest
            }
            .asDriver(onErrorDriveWith: Driver.empty())
        
        let afterTappedChallengeInfoButton = input.tappedChallengeInfoButton
        
        let afterTappedNavigationBarRightButton = input.tappedNavigationBarRightButton
        
        return Output(
            myContributionCountResult: myContributionCountResult,
            challengeInfoResult: challengeInfoResult,
            myChallengeLevelResult: myChallengeLevelResult,
            afterTappedChallengeInfoButton: afterTappedChallengeInfoButton,
            afterTappedNavigationBarRightButton: afterTappedNavigationBarRightButton,
            error: combinedError
        )
    }
    
    private func loadMyContributedCountAPI(userId: String) -> Single<AVIROMyContributionCountDTO> {
        return Single.create { single in
            AVIROAPIManager().loadMyContributedCount(with: userId) { result in
                switch result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    private func loadChallengeInfoAPI() -> Single<AVIROChallengeInfoDTO> {
        return Single.create { single in
            AVIROAPIManager().loadChallengeInfo { result in
                switch result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private func loadMyChallengeLevelAPI(userId: String) -> Single<AVIROMyChallengeLevelResultDTO> {
        return Single.create { single in
            AVIROAPIManager().loadMyChallengeLevel(with: userId) { result in
                switch result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
