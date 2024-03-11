//
//  FirstPopupCollectionViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/12.
//

import UIKit

final class FirstPopupCollectionViewCell: UICollectionViewCell {
    static let identifier = FirstPopupCollectionViewCell.description()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .gray6
        view.roundTopCorners(cornerRadius: 20)
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    private func setupLayout() {
        [
            imageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
