//
//  ChallengeInfoYellowView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/25.
//

import UIKit

final class ChallengeInfoYellowView: UIView {
    private lazy var explainImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .challengeInfoYellow
        
        return imageView
    }()
    
    private lazy var subLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "포인트를 모아보세요!"
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 10, weight: .regular)
        lbl.textAlignment = .left
        
        return lbl
    }()
    
    private lazy var explainLabel: UILabel = {
        let label = UILabel()
        
        label.text = "가게를 등록하고 후기를 작성해서\n나의 나무를 키워보세요!"
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
            subLabel,
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
            
            subLabel.topAnchor.constraint(equalTo: explainImage.topAnchor),
            subLabel.leadingAnchor.constraint(equalTo: explainImage.trailingAnchor, constant: 10),
            subLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            explainLabel.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 6),
            explainLabel.leadingAnchor.constraint(equalTo: explainImage.trailingAnchor, constant: 10),
            explainLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
        self.layer.cornerRadius = 8
    }
}
