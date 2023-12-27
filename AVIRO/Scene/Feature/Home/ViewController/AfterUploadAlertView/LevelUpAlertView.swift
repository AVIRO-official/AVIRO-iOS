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
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    private lazy var tropyImageView: UIImageView = {
        let imageView = UIImageView()
        
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
        
        ])
    }
    
    private func setupAttribute() {
        
    }
    
    func setMainTitle(with level: Int) {
        mainTitle.text = "축하해요!\n레벨 \(level) 달성했어요!"
    }
    
    @objc private func tappedCheckButton(_ sender: UIButton) {
        
    }
    
    @objc private func tappedNoCheckButton(_ sender: UIButton) {
        
    }
}
