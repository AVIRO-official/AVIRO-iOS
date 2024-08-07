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
        
        label.text = MyData.my.nickname
        label.textColor = .gray0
        label.font = .pretendard(size: 20, weight: .semibold)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var treeImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 150/2
        imageView.backgroundColor = .gray7
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.challengeImageBorder.cgColor
        
        return imageView
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        
        view.style = .large
        view.color = .gray5
        view.startAnimating()
        view.isHidden = true
        
        return view
    }()
    
    private lazy var levelView: ChallengeLevelView = {
        let view = ChallengeLevelView()
                
        return view
    }()
    
    private lazy var blurEffectViewForTutorial = BlurEffectView()
    private lazy var speechBubbleViewForCharacterExplain = UIImageView(image: .speechBubble3)
    
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
            nameLabel,
            levelView,
            blurEffectViewForTutorial,
            treeImageView,
            indicatorView,
            speechBubbleViewForCharacterExplain
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            treeImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            treeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            treeImageView.widthAnchor.constraint(equalToConstant: 155),
            treeImageView.heightAnchor.constraint(equalToConstant: 155),
            
            levelView.topAnchor.constraint(equalTo: treeImageView.topAnchor, constant: 84),
            levelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            levelView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            levelView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: treeImageView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: treeImageView.centerYAnchor),
            
            blurEffectViewForTutorial.topAnchor.constraint(equalTo: self.topAnchor),
            blurEffectViewForTutorial.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurEffectViewForTutorial.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurEffectViewForTutorial.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            speechBubbleViewForCharacterExplain.topAnchor.constraint(
                equalTo: treeImageView.bottomAnchor,
                constant: 8
            ),
            speechBubbleViewForCharacterExplain.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        blurEffectViewForTutorial.isHidden = false
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    func blurEffectHidden(_ isHidden: Bool) {
        blurEffectViewForTutorial.isHidden = isHidden
        speechBubbleViewForCharacterExplain.isHidden = isHidden
    }
    
    func startIndicator() {
        indicatorView.isHidden = false
    }
    
    func endIndicator() {
        indicatorView.isHidden = true
    }
    
    func bindData(with result: AVIROMyChallengeLevelDataDTO) {
        let total = result.total
        let rank = result.userRank
        let level = result.level
        let point = result.point
        let pointForNext = result.pointForNext
        let imageURL = URL(string: result.image)!
        
        nameLabel.text = "\(MyData.my.nickname)님의 나무"
        
        if level == 1 && point == 0 {
            levelView.updateLankLabel(with: "포인트를 모아 나무를 성장시켜보세요!")
        } else {
            levelView.updateLankLabel(with: "참여중인 \(total)명 중 \(rank)등이에요!")
        }
        
        levelView.updateLevelLabel(with: "레벨 \(level) 달성했어요!")
        levelView.updateLevelPoint(with: LevelPoint("\(point)", "\(pointForNext)"))
        
        bindingImage(with: imageURL)
    }
    
    private func bindingImage(with url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
             guard let self = self else { return }

             if let error = error {
                 print("이미지 다운로드 실패: \(error)")
                 return
             }

             if let data = data, let image = UIImage(data: data) {
                 DispatchQueue.main.async {
                     self.treeImageView.image = image
                }
             }
         }.resume()
    }
}
