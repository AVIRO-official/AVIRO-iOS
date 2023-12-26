//
//  ChallengeTitleView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

import RxSwift
import RxCocoa

final class ChallengeTitleView: UIView {
    private var viewModel: ChallengeViewModel!
    
    var challengeInfoButtonTap: Driver<Void> {
        return challengeInfoButton.rx.tap.asDriver()
    }
    
    private lazy var challengeDateLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray2
        label.font = .pretendard(size: 17, weight: .medium)
        
        return label
    }()
    
    private lazy var challengeTitleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray0
        label.font = .pretendard(size: 32, weight: .semibold)
        
        return label
    }()
    
    private lazy var challengeLabel: UILabel = {
        let label = UILabel()
        
        label.text = "챌린지"
        label.textColor = .gray0
        label.font = .pretendard(size: 32, weight: .medium)
        
        return label
    }()
    
    private lazy var challengeInfoButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage.infoCircle, for: .normal)
        
        return button
    }()
    
    init(with viewModel: ChallengeViewModel) {
        super.init(frame: .zero)
        
        self.viewModel = viewModel
        
        setupLayout()
        setupAttribute()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            challengeDateLabel,
            challengeTitleLabel,
            challengeLabel,
            challengeInfoButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            challengeDateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            challengeDateLabel.topAnchor.constraint(equalTo: self.topAnchor),
            
            challengeTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            challengeTitleLabel.topAnchor.constraint(equalTo: challengeDateLabel.bottomAnchor, constant: 8),
            
            challengeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            challengeLabel.topAnchor.constraint(equalTo: challengeTitleLabel.bottomAnchor, constant: 2),
            
            challengeInfoButton.centerYAnchor.constraint(equalTo: challengeLabel.centerYAnchor),
            challengeInfoButton.leadingAnchor.constraint(equalTo: challengeLabel.trailingAnchor, constant: 5)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    // TODO: DataBinding 설계 시 삭제 예정
    func updateDate(with date: String) {
        challengeDateLabel.text = date
    }
    
    func updateTitle(with title: String) {
        challengeTitleLabel.text = title
    }
}
