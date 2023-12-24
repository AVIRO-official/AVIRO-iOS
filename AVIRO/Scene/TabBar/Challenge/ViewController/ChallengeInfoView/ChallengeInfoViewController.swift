//
//  ChallengeInfoViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/24.
//

import UIKit

import RxSwift
import RxCocoa

final class ChallengeInfoViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var titleLabelView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupAttribute() {
        view.backgroundColor = .gray5
        
        let panGesture = UIPanGestureRecognizer()
        self.view.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .asDriver()
            .drive(onNext: { [weak self] gesture in
                self?.handlePanGesture(with: gesture)
            })
            .disposed(by: disposeBag)
    }
    
    private func handlePanGesture(with gesture: UIPanGestureRecognizer) {
        let maxUpwardSwipeHeight: CGFloat = 20.0
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y < 0 {
                view.transform = CGAffineTransform(
                    translationX: 0,
                    y: -maxUpwardSwipeHeight
                )
            } else {
                view.transform = CGAffineTransform(
                    translationX: 0,
                    y: translation.y
                )
            }
            
        case .ended, .cancelled:
            if translation.y > 0 && velocity.y > 800 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
    }
}
