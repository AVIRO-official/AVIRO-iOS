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
    
    private lazy var greenView: ChallengeInfoGreenView = {
        let view = ChallengeInfoGreenView()
        
        return view
    }()
    
    private lazy var yellowView: ChallengeInfoYellowView = {
        let view = ChallengeInfoYellowView()
        
        return view
    }()
    
    private lazy var orangeView: ChallengeInfoOrangeView = {
        let view = ChallengeInfoOrangeView()
        
        return view
    }()
    
    private lazy var helpfulLabel: UILabel = {
        let label = UILabel()
        
        label.text = "어비로에 새로운 정보를 등록하면, 더 많은 사람들이 비건을 선택하는 데 도움이 돼요."
        label.setLineSpacing(4)
        label.textColor = .gray2
        label.numberOfLines = 2
        label.font = .pretendard(size: 14, weight: .regular)
        
        return label
    }()
    
    private lazy var baseLabel: UILabel = {
        let label = UILabel()
        
        label.text = "비건 채식은 육류가 포함된 식단보다 탄소 배출을 75%나 적게 하고, 생물 다양성 파괴를 66%까지 줄여요"
        label.setLineSpacing(4)
        label.textColor = .gray2
        label.numberOfLines = 2
        label.font = .pretendard(size: 14, weight: .regular)
        
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let btn = UIButton()
        
        btn.setTitle("이해했어요", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.titleLabel?.font = .pretendard(size: 16, weight: .semibold)
        btn.backgroundColor = .main
        btn.layer.cornerRadius = 28
        
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
            baseLabel,
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
            
            helpfulLabel.topAnchor.constraint(equalTo: orangeView.bottomAnchor, constant: 8),
            helpfulLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            helpfulLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            baseLabel.topAnchor.constraint(equalTo: helpfulLabel.bottomAnchor, constant: 8),
            baseLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 31),
            baseLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -31),
          
            dismissButton.topAnchor.constraint(equalTo: baseLabel.bottomAnchor, constant: 31),
            dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 31),
            dismissButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            dismissButton.heightAnchor.constraint(equalToConstant: 55)
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
