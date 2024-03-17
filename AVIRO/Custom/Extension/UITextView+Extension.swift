//
//  UITextView+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

import UIKit

extension UITextView {
    func numberOfLine() -> Int {
        
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / (self.font!.lineHeight))
    }
}
