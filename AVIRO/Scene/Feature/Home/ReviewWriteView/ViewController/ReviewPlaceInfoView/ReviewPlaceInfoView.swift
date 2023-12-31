//
//  ReviewPlaceInfoView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//

import UIKit

final class ReviewPlaceInfoView: UIView {
    private lazy var placeIcon: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .allCell
        
        return imageView
    }()
    
    private lazy var placeTitle: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 18, weight: .semibold)
        label.textColor = .gray1
        label.textAlignment = .left
        label.numberOfLines = 1
                
        return label
    }()
    
    private lazy var placeAddress: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 15, weight: .regular)
        label.textColor = .gray3
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byClipping
                
        return label
    }()
    
    private var afterViewDidLoad = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !afterViewDidLoad {
            afterViewDidLoad.toggle()
            afterViewDidLoadLayout()
        }
    }
    
    private func setupLayout() {
        [
            placeIcon,
            placeTitle,
            placeAddress
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            placeIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            placeIcon.widthAnchor.constraint(equalToConstant: 24),
            placeIcon.heightAnchor.constraint(equalToConstant: 24),
            
            placeTitle.centerYAnchor.constraint(equalTo: placeIcon.centerYAnchor),
            placeTitle.leadingAnchor.constraint(equalTo: placeIcon.trailingAnchor, constant: 4),
            placeTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            placeAddress.topAnchor.constraint(equalTo: placeIcon.bottomAnchor, constant: 5),
            placeAddress.leadingAnchor.constraint(equalTo: placeIcon.leadingAnchor),
            placeAddress.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray6
        self.layer.cornerRadius = 10
    }
    
    private func afterViewDidLoadLayout() {
        let height = placeIcon.frame.height + placeAddress.frame.height + 5 + 40
        
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func dataBinding(
        icon: UIImage,
        title: String,
        address: String
    ) {
        placeIcon.image = icon
        placeTitle.text = title
        placeAddress.text = address
    }
}
