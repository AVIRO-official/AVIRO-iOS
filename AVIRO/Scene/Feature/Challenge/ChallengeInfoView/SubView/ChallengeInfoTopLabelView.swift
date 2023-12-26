//
//  ChallengeInfoTopLabelView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/25.
//

import UIKit

final class ChallengeInfoTopLabelView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray0
        label.font = .pretendard(size: 20, weight: .semibold)
        label.textAlignment = .center
        
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
            titleLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    func changeTtitleLabel(with title: String) {
        titleLabel.text = "\(title) 챌린지"
    }
}
