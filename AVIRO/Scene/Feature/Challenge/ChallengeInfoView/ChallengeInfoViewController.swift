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
    private var challengeLabel: String!
    
    private lazy var titleLabelView: ChallengeInfoTopLabelView = {
        let view = ChallengeInfoTopLabelView()
        
        view.changeTtitleLabel(with: challengeLabel)
        
        return view
    }()
    
    private lazy var yellowView: ChallengeInfoYellowView = {
        let view = ChallengeInfoYellowView()
        
        return view
    }()
    
    private lazy var greenView: ChallengeInfoGreenView = {
        let view = ChallengeInfoGreenView()
        
        return view
    }()
    
    
    private lazy var orangeView: ChallengeInfoOrangeView = {
        let view = ChallengeInfoOrangeView()
        
        return view
    }()
        
    private lazy var helpfulLabel: UILabel = {
        let label = UILabel()
        
        label.text = "출처 : Peter Scarborough 「Vegans, vegetarians, fish-eaters and meat-eaters in the UK show discrepant environmental impacts」 「Naturefood」, 20 July 2023"
        label.setLineSpacing(4)
        label.textColor = .gray2
        label.numberOfLines = 2
        label.font = .pretendard(size: 9.5, weight: .regular)
        
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let btn = UIButton()
        
        btn.setTitle("이해했어요", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.titleLabel?.font = .pretendard(size: 16, weight: .semibold)
        btn.backgroundColor = .keywordBlue
        btn.layer.cornerRadius = 15
        
        return btn
    }()
        
    static func create(with challenge: String) -> ChallengeInfoViewController {
        let vc = ChallengeInfoViewController()
        
        vc.challengeLabel = challenge
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    private func setupLayout() {
        [
            titleLabelView,
            greenView,
            yellowView,
            orangeView,
            helpfulLabel,
            dismissButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabelView.topAnchor.constraint(equalTo: self.view.topAnchor),
            titleLabelView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            titleLabelView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            titleLabelView.heightAnchor.constraint(equalToConstant: 65),
            
            greenView.topAnchor.constraint(equalTo: titleLabelView.bottomAnchor, constant: 30),
            greenView.heightAnchor.constraint(equalToConstant: 80),
            greenView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            greenView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            yellowView.topAnchor.constraint(equalTo: greenView.bottomAnchor, constant: 15),
            yellowView.heightAnchor.constraint(equalToConstant: 80),
            yellowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            yellowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            orangeView.topAnchor.constraint(equalTo: yellowView.bottomAnchor, constant: 15),
            orangeView.heightAnchor.constraint(equalToConstant: 80),
            orangeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            orangeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            helpfulLabel.topAnchor.constraint(equalTo: orangeView.bottomAnchor, constant: 15),
            helpfulLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            helpfulLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            dismissButton.topAnchor.constraint(equalTo: helpfulLabel.bottomAnchor, constant: 20),
            dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            dismissButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            dismissButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupAttribute() {
        view.backgroundColor = .gray6
        self.view.roundTopCorners(cornerRadius: 20)
        
        let panGesture = UIPanGestureRecognizer()
        self.view.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .asDriver()
            .drive(onNext: { [weak self] gesture in
                self?.handlePanGesture(with: gesture)
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
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
                UIView.animate(withDuration: 0.2) {
                    self.view.transform = CGAffineTransform(
                        translationX: 0,
                        y: -maxUpwardSwipeHeight
                    )
                }
            } else {
                view.transform = CGAffineTransform(
                    translationX: 0,
                    y: translation.y
                )
            }
            
        case .ended, .cancelled:
            if translation.y > 0 && velocity.y > 800 {
                self.dismiss(animated: true)
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
