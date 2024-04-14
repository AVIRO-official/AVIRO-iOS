//
//  BlurEffectView.swift
//  AVIRO
//
//  Created by 전성훈 on 4/13/24.
//

import UIKit

final class BlurEffectView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupAttribute() {
        self.backgroundColor = .black
        self.alpha = 0.6
        
        self.isHidden = true
    }
}
