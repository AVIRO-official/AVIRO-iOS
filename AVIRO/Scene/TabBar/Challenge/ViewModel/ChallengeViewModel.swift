//
//  ChallengeViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import RxSwift
import RxCocoa

final class ChallengeViewModel: ViewModel {
    struct Input {
        let tappedChallengeInfoButton: Driver<Void>
        let tappedNavigationBarRightButton: Driver<Void>
    }
    
    struct Output {
        let afterTappedChallengeInfoButton: Driver<Void>
        let afterTappedNavigationBarRightButton: Driver<Void>
    }
    
    func transform(with input: Input) -> Output {
        
        let afterTappedChallengeInfoButton = input.tappedChallengeInfoButton
        
        let afterTappedNavigationBarRightButton = input.tappedNavigationBarRightButton
        
        return Output(
            afterTappedChallengeInfoButton: afterTappedChallengeInfoButton,
            afterTappedNavigationBarRightButton: afterTappedNavigationBarRightButton
        )
    }
}
