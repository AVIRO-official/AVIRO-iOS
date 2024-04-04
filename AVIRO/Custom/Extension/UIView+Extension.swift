//
//  UIView+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/12.
//

import UIKit

extension UIView {
    func roundTopCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = CACornerMask(arrayLiteral: [
            .layerMinXMinYCorner, .layerMaxXMinYCorner]
        )
    }
    
    func roundBottomCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = CACornerMask(arrayLiteral: [
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        )
    }
}
