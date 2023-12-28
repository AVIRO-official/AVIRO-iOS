//
//  RecommendPlaceAlertView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/27.
//

import UIKit

final class RecommendPlaceAlertView: UIView {
    var afterTappedRecommendButton: (() -> Void)?
    var afterTappedNoRecommendButton: (() -> Void)?
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.textColor = .gray0
        label.font = .pretendard(size: 20, weight: .bold)
        label.setLineSpacing(3)
        label.textAlignment = .center
        label.text = "이 가게를\n추천하시겠어요?"
        
        return label
    }()
    
    private lazy var recommendButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("네! 추천할래요!", for: .normal)
        button.setTitleColor(.gray7, for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.backgroundColor = .keywordBlue
        button.layer.cornerRadius = 10
        button.addTarget(
            self,
            action: #selector(tappedRecommendButton(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var noRecommendButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("아니요, 안할래요", for: .normal)
        button.setTitleColor(.gray3, for: .normal)
        button.titleLabel?.font = .pretendard(size: 14, weight: .regular)
        button.backgroundColor = .gray7
        button.addTarget(
            self,
            action: #selector(tappedNoRecommendButton(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
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
            mainLabel,
            recommendButton,
            noRecommendButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            mainLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            recommendButton.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 15),
            recommendButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recommendButton.heightAnchor.constraint(equalToConstant: 45),
            recommendButton.widthAnchor.constraint(equalToConstant: 150),
            
            noRecommendButton.topAnchor.constraint(equalTo: recommendButton.bottomAnchor, constant: 10),
            noRecommendButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            noRecommendButton.heightAnchor.constraint(equalToConstant: 25),
            noRecommendButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
        self.layer.cornerRadius = 15
    }
    
    @objc private func tappedRecommendButton(_ sender: UIButton) {
        afterTappedRecommendButton?()
    }
    
    @objc private func tappedNoRecommendButton(_ sender: UIButton) {
        afterTappedNoRecommendButton?()
    }
}
