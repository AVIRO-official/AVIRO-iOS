//
//  CommentsLabel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/04.
//

import UIKit

class CommentsLabel: UILabel {

    private var topInset: CGFloat = 10.0
    private var bottomInset: CGFloat = 10.0
    private var leftInset: CGFloat = 16.0
    private var rightInset: CGFloat = 16.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textColor = .gray0
        self.backgroundColor = .gray6
        
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        self.font = .systemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
