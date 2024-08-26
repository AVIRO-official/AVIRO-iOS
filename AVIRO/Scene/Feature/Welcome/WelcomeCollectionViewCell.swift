//
//  WellcomeCollectionViewCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/12.
//

import UIKit

final class WelcomeCollectionViewCell: UICollectionViewCell {
    static let identifier = WelcomeCollectionViewCell.description()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .gray5
        
        return view
    }()
    
    private lazy var failureLabel: UILabel = {
        let lbl = UILabel()
       
        lbl.text = "이미지 로딩에 실패했습니다."
        lbl.numberOfLines = 2
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 16, weight: .semibold)
        lbl.isHidden = true
        
        return lbl
    }()
    
    private lazy var checkButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .all
        btn.setTitle("지금 확인하기", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.titleLabel?.font = .pretendard(size: 18, weight: .bold)
        
        btn.addTarget(self, action: #selector(checkButtonTapped(_:)), for: .touchUpInside)
        
        return btn
    }() 
    
    var didTappedCheckButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        failureLabel.isHidden = true
    }
    
    private func setupLayout() {
        [
            imageView,
            failureLabel,
            checkButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            failureLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            failureLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            checkButton.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            checkButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            checkButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            checkButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            checkButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 15
    }
    
    // TODO: 추후 모델링
    func configure(with welcomePopupData: WelcomePopup) {
        URLSession.shared.dataTask(with: welcomePopupData.imageURL) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let _ = error {
                DispatchQueue.main.async {
                    self.imageLoadFail()
                }
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }.resume()
        
        checkButton.backgroundColor = UIColor(
            hex: welcomePopupData.buttonColor
        )
    }
    
    private func imageLoadFail() {
        failureLabel.isHidden = false
    }
    
    @objc private func checkButtonTapped(_ sender: UIButton) {
        didTappedCheckButton?()
    }
}
