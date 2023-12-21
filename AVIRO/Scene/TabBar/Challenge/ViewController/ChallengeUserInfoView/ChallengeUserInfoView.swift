//
//  ChallengeUserInfoView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

final class ChallengeUserInfoView: UIView {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray0
        label.font = .pretendard(size: 20, weight: .semibold)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var treeImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 150/2
        imageView.backgroundColor = .gray7
        
        return imageView
    }()
    
    private lazy var levelView: ChallengeLevelView = {
        let view = ChallengeLevelView()
                
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
        test()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            nameLabel,
            levelView,
            treeImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            treeImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            treeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            treeImageView.widthAnchor.constraint(equalToConstant: 150),
            treeImageView.heightAnchor.constraint(equalToConstant: 150),
            
            levelView.topAnchor.constraint(equalTo: treeImageView.topAnchor, constant: 84),
            levelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            levelView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            levelView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    // TODO: Binding 작업 시 수정
    private func test() {
        nameLabel.text = "천재강쥐또또님의 나무"
        
        levelView.updateLankLabel(with: "참여중인 300명 중 20등이에요!")
        levelView.updateLevelLabel(with: "레벨 1을 달성했어요!")
        levelView.updateLevelPoint(with: LevelPoint("30", "90"))
    }
}
