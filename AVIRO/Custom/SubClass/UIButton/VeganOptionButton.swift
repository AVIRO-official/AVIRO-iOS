//
//  VeganOptionButton.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/23.
//

import UIKit

final class VeganOptionButton: UIButton {
    private let spacing: CGFloat = 32

    var changedColor: UIColor?

    private var change = false

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? changedColor : .gray6
            self.tintColor = isSelected ? .gray7 : .gray2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setAttribute() {
        backgroundColor = .gray6
    
        layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !change {
            change.toggle()
            setButtonSize()
            verticalTitleToImage()
        }
    }
    
    // MARK: SetUp Button
    func setButton(
        _ veganOption: VeganOption
    ) {
        let title = veganOption.buttontitle
        let image = veganOption.icon
                
        setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        let attributedString = NSMutableAttributedString(string: title)
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 5
        
        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSRange(
                location: 0,
                length: attributedString.length
            )
        )
        attributedString.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor.gray3,
            range: NSRange(
                location: 0,
                length: attributedString.length
            )
        )
        
        setAttributedTitle(attributedString, for: .normal)
        
        let attributedStringSelected = NSMutableAttributedString(string: title)
        
        attributedStringSelected.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSRange(
                location: 0,
                length: attributedStringSelected.length
            )
        )
        attributedStringSelected.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor.gray7,
            range: NSRange(
                location: 0,
                length: attributedStringSelected.length
            )
        )
        
        setAttributedTitle(attributedStringSelected, for: .selected)

        titleLabel?.font = .pretendard(size: 15, weight: .bold)
        titleLabel?.numberOfLines = 2
        
        tintColor = .gray2
    }
    
    // MARK: Vertical Title -> Image
    private func verticalTitleToImage() {
        let titleHeight = titleLabel?.frame.height ?? 0
        
        let imageHeight = imageView?.frame.height ?? 0
        let imageWidth = imageView?.frame.width ?? 0
        
        titleEdgeInsets = UIEdgeInsets(
            top: -(imageHeight + spacing),
            left: -imageWidth,
            bottom: 0.0,
            right: 0.0
        )
        
        imageEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: -(titleHeight + spacing),
            right: -(self.frame.width)
        )
    }
    
    // MARK: button 높이 & 넓이 설정
    private func setButtonSize() {
        let depth: CGFloat = 20.0

        let superViewWitdh: CGFloat = Double(self.superview?.frame.width ?? 0)

        let buttonWidth = (superViewWitdh - depth) / 3
        
        self.widthAnchor.constraint(
            equalToConstant: buttonWidth).isActive = true
        
        // image Height + title Height + spacing + padding
        let imageHeight = imageView?.frame.height ?? 0
        let titleHeight = titleLabel?.frame.height ?? 0
        let padding: CGFloat = 24
        
        let totalHeight = imageHeight + titleHeight + padding + spacing

        self.heightAnchor.constraint(
            equalToConstant: totalHeight).isActive = true
    }
}
