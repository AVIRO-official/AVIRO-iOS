//
//  ChallengeViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import RxSwift
import RxCocoa

// TODO: DTO -> Domain으로 변경 필요
// Clean Architecture 적용 시 수정

protocol ChallengeViewModelProtocol: AnyObject {
    var whenUpdateBookmarkList: Bool { get set }
}

final class ChallengeViewModel: ViewModel, ChallengeViewModelProtocol {
    private var bookmarkManager: BookmarkFacadeProtocol!
    
    var challengeTitle: String = ""
    
    var whenUpdateBookmarkList = false
    
    init(bookmarkManager: BookmarkFacadeProtocol) {
        self.bookmarkManager = bookmarkManager
    }
    
    struct Input {
        let whenViewWillAppear: Driver<Void>
        let whenRefesh: Driver<Void>
        let tappedChallengeInfoButton: Driver<Void>
        let tappedNavigationBarRightButton: Driver<Void>
    }
    
    struct Output {
        let myContributionCountResult: Driver<AVIROMyActivityCounts>
        let challengeInfoResult: Driver<AVIROChallengeInfoDataDTO>
        let myChallengeLevelResult: Driver<AVIROMyChallengeLevelDataDTO>
        
        let afterTappedChallengeInfoButton: Driver<Void>
        let afterTappedNavigationBarRightButton: Driver<Void>
        let error: Driver<APIError>
    }
    
    func transform(with input: Input) -> Output {
        let loadInfoTrigger = Driver.merge(input.whenViewWillAppear, input.whenRefesh)
        
        let challengeInfoError = PublishSubject<Error>()
        let myContributionCountError = PublishSubject<Error>()
        let myChallengeLevelError = PublishSubject<Error>()
        
        // TODO: - Image 불러오는 API 확인
        
        // 3개의 api가 하나의 loadInfoTrigger stream을 받고있어서 간헐적으로 api 호출이 실패함
        // 순차적으로 api 호출하도록 각각의 result을 연결
        let challengeInfoResult = loadInfoTrigger
            .flatMap { [weak self] in
                guard let self = self else {
                    return Driver<AVIROChallengeInfoDataDTO>.empty()
                }
                return self.loadChallengeInfoAPI()
                    .asDriver(onErrorRecover: { error in
                        challengeInfoError.onNext(error)
                        return Driver.empty()
                    })
            }
        
        let myChallengeLevelResult = challengeInfoResult
            .flatMap { [weak self] _ in
                guard let self = self else {
                    return Driver<AVIROMyChallengeLevelDataDTO>.empty()
                }
                return self.loadMyChallengeLevelAPI(userId: MyData.my.id)
                    .asDriver(onErrorRecover: { error in
                        myChallengeLevelError.onNext(error)
                        return Driver.empty()
                    })
            }
        
        let myContributionCountResult = myChallengeLevelResult
            .flatMap { [weak self] _ in
                guard let self = self else {
                    return Driver<AVIROMyActivityCounts>.empty()
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
    
    /// 개선 필요
    private func loadMyContributedCountAPI(userId: String) -> Single<AVIROMyActivityCounts> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            func makeApiCall() {
                AVIROAPI.manager.loadMyContributedCount(with: userId) { result in
                    switch result {
                    case .success(let data):
                        
                        guard let resultData = data.data else { return }
                        
                        var newModel = AVIROMyActivityCounts(
                            placeCount: resultData.placeCount,
                            commentCount: resultData.commentCount,
                            bookmarkCount: self.bookmarkManager.loadAllData().count
                        )
                        
                        single(.success(newModel))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            }
            
            if self.whenUpdateBookmarkList {
                self.whenUpdateBookmarkList.toggle()
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.8, execute: makeApiCall)
            } else {
                makeApiCall()
            }
            
            return Disposables.create()      
        }
    }
    
    private func loadChallengeInfoAPI() -> Single<AVIROChallengeInfoDataDTO> {
        return Single.create { single in
            AVIROAPI.manager.loadChallengeInfo { result in
                switch result {
                case .success(let resultModel):
                    guard let resultData = resultModel.data else { return }
                                        
                    single(.success(resultData))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private func loadMyChallengeLevelAPI(userId: String) -> Single<AVIROMyChallengeLevelDataDTO> {
        return Single.create { single in
            AVIROAPI.manager.loadMyChallengeLevel(with: userId) { result in
                switch result {
                case .success(let resultModel):
                    guard let resultData = resultModel.data else { return }
                    
                    single(.success(resultData))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
