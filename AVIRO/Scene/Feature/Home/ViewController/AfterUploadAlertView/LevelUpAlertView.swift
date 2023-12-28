//
//  LevelUpAlertView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/27.
//

import UIKit

final class LevelUpAlertView: UIView {
    var afterTappedCheckButtonTapped: (() -> Void)?
    var afterTappedNoCheckButtonTapped: (() -> Void)?
    
    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        
        let opacityKeyframe = CAKeyframeAnimation(keyPath: "opacity")
        opacityKeyframe.values = [
            0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1
        ]
        opacityKeyframe.keyTimes = [
            0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1
        ]
        opacityKeyframe.duration = 1
        opacityKeyframe.repeatCount = 1

        view.layer.cornerRadius = 15
        view.image = .goldRectangle
        view.backgroundColor = .clear
        view.layer.add(opacityKeyframe, forKey: "BackgroundImageAnimation")
        
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    private lazy var tropyImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .goldTrophy
        
        return imageView
    }()
    
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.textColor = .gray0
        label.font = .pretendard(size: 20, weight: .bold)
        label.setLineSpacing(3)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("지금 확인할래요!", for: .normal)
        button.setTitleColor(.gray7, for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.backgroundColor = .keywordBlue
        button.layer.cornerRadius = 10
        button.addTarget(
            self,
            action: #selector(tappedCheckButton(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var noCheckButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("아니요, 다음에 볼게요", for: .normal)
        button.setTitleColor(.gray3, for: .normal)
        button.titleLabel?.font = .pretendard(size: 14, weight: .regular)
        button.backgroundColor = .gray7
        button.addTarget(
            self,
            action: #selector(tappedNoCheckButton(_:)),
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
            backgroundImageView,
            contentView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(
                equalTo: self.topAnchor
            ),
            backgroundImageView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor
            ),
            backgroundImageView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor
            ),
            backgroundImageView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor
            ),
            
            contentView.topAnchor.constraint(
                equalTo: backgroundImageView.topAnchor,
                constant: 45
            ),
            contentView.leadingAnchor.constraint(
                equalTo: backgroundImageView.leadingAnchor,
                constant: 45
            ),
            contentView.trailingAnchor.constraint(
                equalTo: backgroundImageView.trailingAnchor,
                constant: -45
            ),
            contentView.bottomAnchor.constraint(
                equalTo: backgroundImageView.bottomAnchor,
                constant: -45
            )
        ])

        [
            tropyImageView,
            mainTitle,
            checkButton,
            noCheckButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tropyImageView.heightAnchor.constraint(equalToConstant: 56),
            tropyImageView.widthAnchor.constraint(equalToConstant: 56),
            tropyImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tropyImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            mainTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainTitle.topAnchor.constraint(equalTo: tropyImageView.bottomAnchor, constant: 10),
            
            checkButton.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 15),
            checkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkButton.heightAnchor.constraint(equalToConstant: 45),
            checkButton.widthAnchor.constraint(equalToConstant: 160),
            
            noCheckButton.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 10),
            noCheckButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noCheckButton.heightAnchor.constraint(equalToConstant: 25),
            noCheckButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupAttribute() {
        self.layer.cornerRadius = 15
        self.backgroundColor = .clear
        
    }
    
    func setMainTitle(with level: Int) {
        mainTitle.text = "축하해요!\n레벨 \(level) 달성했어요!"
    }
    
    @objc private func tappedCheckButton(_ sender: UIButton) {
        afterTappedCheckButtonTapped?()
    }
    
    @objc private func tappedNoCheckButton(_ sender: UIButton) {
        afterTappedNoCheckButtonTapped?()
    }
}
