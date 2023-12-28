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
        return 0.15
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // 프레젠테이션될 뷰 컨트롤러입니다.
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = transitionContext.containerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        
        let containerView = transitionContext.containerView
        containerView.addSubview(blurEffectView)
        containerView.addSubview(toViewController.view)
        
        let finalFrame = CGRect(
            x: 0,
            y: containerView.frame.height - 560,
            width: containerView.bounds.width,
            height: 580
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
                blurEffectView.alpha = 0.4
                transitionContext.completeTransition(finished)
            }
        )
    }
}
