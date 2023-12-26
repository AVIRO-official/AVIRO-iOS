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
//        let error: Driver<APIError>
    }
    
    func transform(with input: Input) -> Output {
        let challengeInfoResult = input.loadData
            .flatMapLatest {
                self.loadChallengeInfoAPI()
                    .asDriver(onErrorDriveWith: Driver.empty())
            }
        
        let myContributionCountResult = input.loadData
            .flatMapLatest {
                self.loadMyContributedCountAPI(userId: MyData.my.id)
                    .asDriver(onErrorDriveWith: Driver.empty())
            }
            
        let myChallengeLevelResult = input.loadData
            .flatMapLatest {
                self.loadMyChallengeLevelAPI(userId: MyData.my.id)
                    .asDriver(onErrorDriveWith: Driver.empty())
            }

        let afterTappedChallengeInfoButton = input.tappedChallengeInfoButton
        
        let afterTappedNavigationBarRightButton = input.tappedNavigationBarRightButton
        
        return Output(
            myContributionCountResult: myContributionCountResult,
            challengeInfoResult: challengeInfoResult,
            myChallengeLevelResult: myChallengeLevelResult,
            afterTappedChallengeInfoButton: afterTappedChallengeInfoButton,
            afterTappedNavigationBarRightButton: afterTappedNavigationBarRightButton
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
