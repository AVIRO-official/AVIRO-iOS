//
//  ChallengeInfoPresentaionDelegate.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import UIKit

class ChallengeInfoPresentaionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return ChallengeInfoPresentationAnimator()
    }
}
