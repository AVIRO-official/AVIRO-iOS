//
//  ChallengeInfoPresentationAnimator.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import UIKit

class ChallengeInfoPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // 프레젠테이션될 뷰 컨트롤러입니다.
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let blurEffectView = BlurEffectView()
        
        let containerView = transitionContext.containerView
        
        blurEffectView.frame = containerView.frame
        blurEffectView.isHidden = false
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(toViewController.view)
        
        // bounce를 위한 height 조정
        let finalFrame = CGRect(
            x: 0,
            y: containerView.frame.height - 500,
            width: containerView.bounds.width,
            height: 520
        )
        
        toViewController.view.frame = finalFrame.offsetBy(
            dx: 0,
            dy: finalFrame.height
        )
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                toViewController.view.frame = finalFrame
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}
