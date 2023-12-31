//
//  UILabel+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/18.
//

import UIKit

extension UILabel {
    func countCurrentLines() -> Int {
        guard let text = self.text else { return 0 }
        
        let rect = CGSize(
            width: self.bounds.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let labelSize = text.boundingRect(
            with: rect,
            options: .usesLineFragmentOrigin,
            attributes: [
                NSAttributedString.Key.font: font ?? CFont.font.medium16],
            context: nil
        )
        
        let numberOfLine = Int(ceil(CGFloat(labelSize.height) / font.lineHeight ))
        
        return numberOfLine
    }
    
    func setLineSpacing(_ spacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: self.text ?? "")
        }

        // .paragraphStyle 속성을 전체 텍스트에 적용합니다.
        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        self.attributedText = attributedString
    }

}
