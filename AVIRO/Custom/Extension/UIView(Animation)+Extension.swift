//
//  UIView+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/12.
//

import UIKit

private enum AniKeyPath: String {
    case position
}

// MARK: - Animaiton Extension
extension UIView {
    private struct AssociatedKeys {
        static var isAnimating = "UIViewIsAnimating"
    }
    
    var isAnimating: Bool {
        get {
            return objc_getAssociatedObject(
                self,
                &AssociatedKeys.isAnimating
            ) as? Bool ?? false
        }
        set(value) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.isAnimating,
                value,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func activeHshakeEffect() {
        let animation = CABasicAnimation(
            keyPath: AniKeyPath.position.rawValue
        )
        
        animation.duration = 0.02
        animation.repeatCount = 3
        animation.autoreverses = true
        
        animation.fromValue = NSValue(cgPoint: CGPoint(
            x: self.center.x - 2,
            y: self.center.y)
        )
        
        animation.toValue = NSValue(cgPoint: CGPoint(
            x: self.center.x + 2,
            y: self.center.y)
        )
        
        self.layer.add(
            animation,
            forKey: AniKeyPath.position.rawValue
        )
    }
    
    func activeExpansion(
        from startingFrame: CGRect,
        to targetView: UIView,
        completion: @escaping () -> Void
    ) {
        let snapshot = self.snapshotView(afterScreenUpdates: true)
        snapshot?.frame = startingFrame

        guard let snapshot = snapshot else { return }
        targetView.addSubview(snapshot)

        let targetScaleX = targetView.frame.width / startingFrame.width
        let targetScaleY = targetView.frame.height / startingFrame.height
        
        UIView.animate(withDuration: 0.15, animations: {
            snapshot.transform = CGAffineTransform(scaleX: targetScaleX, y: targetScaleY)
            snapshot.center = targetView.center

        }, completion: { _ in
            completion()
            snapshot.removeFromSuperview()
        })
    }
    
    func roundTopCorners(cornerRadius: CGFloat) {
        self.layoutIfNeeded()
        self.layer.masksToBounds = true
        
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: [.topRight, .topLeft],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    /// 이 메서드는 사용자가 뷰를 터치하거나 터치를 해제할 때 호출될 수 있으며,
    /// 터치 시 뷰의 크기를 일시적으로 줄였다가 원래대로 되돌리는 효과를 제공합니다.
    /// 애니메이션이 완료되면 `isAnimating` 상태가 업데이트 되며, 필요에 따라
    /// 애니메이션 완료 후 실행할 작업을 `completion` 블록을 통해 제공할 수 있습니다.
    ///
    /// - Parameters:
    ///   - isTouchDown: 사용자가 뷰를 터치했을 때는 `true`, 터치를 해제했을 때는 `false`로 설정합니다.
    ///   - scale: 뷰를 축소할 비율. 기본값은 0.96(원래 크기의 96%)입니다.
    ///   - completion: 애니메이션이 완료된 후 실행할 작업입니다. 필요에 따라 클로저 형태로 작업을 제공할 수 있습니다.
    ///
    ///   처음 시작 시 animation이 시작하고 animation이 진행 중 일땐 진행 중인 animation이 끝나면 시작됩니다.
    func animateTouchResponse(
        isTouchDown: Bool,
        scale: CGFloat = 0.96,
        duration: Double = 0.05,
        completion: (() -> Void)? = nil
    ) {
        if !isAnimating {
            isAnimating = true

            UIView.animate(
                withDuration: duration,
                animations: {
                    self.transform =
                    isTouchDown
                        ? CGAffineTransform(scaleX: scale, y: scale)
                        : .identity
                }, completion: { [weak self] _ in
                    self?.isAnimating = false
                    completion?()
                }
            )
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(
                    withDuration: duration,
                    animations: {
                        self.transform =
                        isTouchDown
                            ? CGAffineTransform(scaleX: scale, y: scale)
                            : .identity
                    }, completion: { [weak self] _ in
                        self?.isAnimating = false
                        completion?()
                    }
                )
            }
        }
    }
}
