////
////  CustomPresentation.swift
////  AVIRO
////
////  Created by 전성훈 on 2023/05/21.
////
//
//import UIKit
//
//// MARK: Present custom
//final class CustomPresentation: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        guard let containerView = containerView else {
//            return .zero
//        }
//        return CGRect(x: 0, y: containerView.bounds.height * 0.7, width: containerView.bounds.width, height: containerView.bounds.height * 0.3)
//    }
//}
//
//class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//    let isPresentation: Bool
//
//    init(isPresentation: Bool) {
//        self.isPresentation = isPresentation
//    }
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.5
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
//        guard let controller = transitionContext.viewController(forKey: key) else { return }
//
//        if isPresentation {
//            transitionContext.containerView.addSubview(controller.view)
//        }
//
//        let presentedFrame = transitionContext.finalFrame(for: controller)
//        var dismissedFrame = presentedFrame
//        dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
//
//        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
//        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
//
//        let animationDuration = transitionDuration(using: transitionContext)
//        controller.view.frame = initialFrame
//        UIView.animate(withDuration: animationDuration, animations: {
//            controller.view.frame = finalFrame
//        }, completion: { finished in
//            if !self.isPresentation {
//                controller.view.removeFromSuperview()
//            }
//            transitionContext.completeTransition(finished)
//        })
//    }
//}
//
////extension HomeViewController: UIViewControllerTransitioningDelegate {
////    func presentationController(
////        forPresented presented: UIViewController,
////        presenting: UIViewController?,
////        source: UIViewController
////    ) -> UIPresentationController? {
////        return CustomPresentation(presentedViewController: presented, presenting: presenting)
////    }
////
////    func animationController(
////        forPresented presented: UIViewController,
////        presenting: UIViewController,
////        source: UIViewController
////    ) -> UIViewControllerAnimatedTransitioning? {
////        return SlideAnimator(isPresentation: true)
////    }
////
////    func animationController(
////        forDismissed dismissed: UIViewController
////    ) -> UIViewControllerAnimatedTransitioning? {
////        return SlideAnimator(isPresentation: false)
////    }
////}
