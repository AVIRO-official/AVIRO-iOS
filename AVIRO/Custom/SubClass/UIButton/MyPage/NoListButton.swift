//
//  WhenNoListButton.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/10.
//

import UIKit

final class NoListButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setAttribute() {
        layer.cornerRadius = 24
        layer.borderColor = UIColor.keywordBlue.cgColor
        layer.borderWidth = 2
        self.backgroundColor = .gray7
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 172),
            self.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func setButton(_ title: String,
                   _ image: UIImage
    ) {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        
        setTitleColor(.keywordBlue, for: .normal)
        titleLabel?.font = CFont.font.semibold16
        
        semanticContentAttribute = .forceLeftToRight
        
        imageEdgeInsets = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 10
        )
        titleEdgeInsets = .init(
            top: 0,
            left: 10,
            bottom: 0,
            right: 0
        )
    }
}
