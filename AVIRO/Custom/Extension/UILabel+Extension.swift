//
//  UILabel+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/18.
//

import UIKit

extension UILabel {
    func countCurrentLines() -> Int {
        let text = self.text ?? ""

        let maxSize = CGSize(width: self.frame.width, height: CGFloat.infinity)
        let textAttributes: [NSAttributedString.Key: Any] = [.font: self.font ?? .pretendard(size: 15, weight: .medium)]

        let rect = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)

        return Int(ceil(rect.height / self.font.lineHeight))
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
