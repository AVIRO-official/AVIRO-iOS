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
        imageView.layer.borderWidth = 5
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
            treeImageView,
            indicatorView
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
            levelView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: treeImageView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: treeImageView.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    func isStartIndicator() {
        indicatorView.isHidden = false
    }
    
    func isEndIndicator() {
        indicatorView.isHidden = true
    }
    
    func bindData(with result: AVIROMyChallengeLevelResultDTO) {
        let total = result.total ?? 0
        let rank = result.userRank ?? 0
        let level = result.level ?? 0
        let point = result.point ?? 0
        let pointForNext = result.pointForNext ?? 100
        let imageURL = URL(string: result.image ?? "")!
        
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
