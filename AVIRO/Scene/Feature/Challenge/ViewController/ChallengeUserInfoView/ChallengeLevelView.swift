//
//  ChallengeLevelView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

typealias LevelPoint = (now: String, gool: String)

final class ChallengeLevelView: UIView {
    private lazy var lankLabel: UILabel = {
        let label = UILabel()
        
        label.text = "포인트를 모아 나무를 성장시켜보세요!"
        label.textColor = .gray0
        label.font = .pretendard(size: 17, weight: .semibold)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var levelLabel: UILabel = {
        let label = UILabel()
        
        label.text = "레벨   달성했어요!"
        label.textColor = .gray2
        label.font = .pretendard(size: 15, weight: .medium)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var levelProgress: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        
        view.trackTintColor = .gray5
        view.progressTintColor = .keywordBlue
        view.setProgress(0.05, animated: true)
        
        return view
    }()
    
    private lazy var levelPointLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.numberOfLines = 1
        
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
            lankLabel,
            levelLabel,
            levelProgress,
            levelPointLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            lankLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lankLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
            
            levelLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: lankLabel.bottomAnchor, constant: 6),
            
            levelProgress.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 26),
            levelProgress.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            levelProgress.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            levelPointLabel.topAnchor.constraint(equalTo: levelProgress.bottomAnchor, constant: 8),
            levelPointLabel.trailingAnchor.constraint(equalTo: levelProgress.trailingAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray6
        self.layer.cornerRadius = 12
        
        
        updateLevelPoint(with: ("0", "30"))
    }
    
    func updateLankLabel(with lank: String) {
        lankLabel.text = lank
    }
    
    func updateLevelLabel(with level: String) {
        levelLabel.text = level
    }
    
    func updateLevelPoint(with levelPoint: LevelPoint) {
        let coloredRange = NSRange(location: 0, length: levelPoint.now.count)
        
        let coloredAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.keywordBlue,
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .medium)
        ]
        
        let grayAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray3,
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .medium)
        ]
        
        let attributedText = NSMutableAttributedString(
            string: [
                levelPoint.now,
                "/",
                levelPoint.gool,
                "P"
            ].joined()
        )
        
        attributedText.addAttributes(
            coloredAttributes,
            range: coloredRange
        )
        attributedText.addAttributes(
            grayAttributes, 
            range: NSRange(
                location: levelPoint.now.count,
                length: attributedText.length - levelPoint.now.count
            )
        )
        
        levelPointLabel.attributedText = attributedText
        
        let currentProgress = Float(levelPoint.now)! / Float(levelPoint.gool)!

        levelProgress.setProgress(currentProgress, animated: false)
    }
}
