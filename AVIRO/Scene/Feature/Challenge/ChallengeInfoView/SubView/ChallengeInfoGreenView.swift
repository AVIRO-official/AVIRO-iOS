//
//  ChallengeInfoGreenView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/25.
//

import UIKit

final class ChallengeInfoGreenView: UIView {
    private lazy var explainImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .challengeInfoGreen
        
        return imageView
    }()
    
    private lazy var explainLabel: UILabel = {
        let label = UILabel()
        
        label.text = "경험치를 모아 레벨업을 해보세요\n무럭무럭 자라는 나무를 볼 수 있어요!"
        label.setLineSpacing(4)
        label.numberOfLines = 2
        label.textColor = .gray0
        label.font = .pretendard(size: 15, weight: .semibold)
        label.textAlignment = .left
        
        return label
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
            explainImage,
            explainLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            explainImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            explainImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            explainImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            explainImage.widthAnchor.constraint(equalToConstant: 60),
            explainImage.heightAnchor.constraint(equalToConstant: 60),
            
            explainLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            explainLabel.leadingAnchor.constraint(equalTo: explainImage.trailingAnchor, constant: 10),
            explainLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
        self.layer.cornerRadius = 8
    }
}
