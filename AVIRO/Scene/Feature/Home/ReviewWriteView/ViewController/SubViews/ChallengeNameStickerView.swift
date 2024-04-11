//
//  ChallengeNameStickerView.swift
//  AVIRO
//
//  Created by 전성훈 on 4/10/24.
//

import UIKit

final class ChallengeNameStickerView: UIView {
    private let textLabel: ChallengeNameStickerLabel = {
        let label = ChallengeNameStickerLabel()
        
        label.font = .pretendard(size: 16, weight: .semibold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .gray7
        label.backgroundColor = .all
        
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        
        return label
    }()
    
    private let arrowView = {
        let view = ArrowView()
        
        view.backgroundColor = .clear
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAttribute()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
        
        activeBouncingEffect(withVerticalOffset: 3, duration: 0.5)
    }
    
    private func setupLayout() {
        self.addSubview(textLabel)
        self.addSubview(arrowView)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            arrowView.widthAnchor.constraint(equalToConstant: 20),
            arrowView.heightAnchor.constraint(equalToConstant: 10),
            arrowView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            arrowView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: -2),
            arrowView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func bindingChallengeName(with challenge: String) {
        textLabel.text = challenge
    }
    
    private final class ChallengeNameStickerLabel: UILabel {
        
        override var intrinsicContentSize: CGSize {
            let originalSize = super.intrinsicContentSize
            
            let width = originalSize.width + 30
            let height = originalSize.height + 20
            
            return CGSize(width: width, height: height)
        }
    }
    
    private final class ArrowView: UIView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            
            let pointTip = CGPoint(x: rect.width / 2, y: 10)
            let pointLeft = CGPoint(x: rect.width / 2 - 10, y: 0)
            let pointRight = CGPoint(x: rect.width / 2 + 10, y: 0)
            
            path.move(to: pointLeft)
            path.addLine(to: pointTip)
            path.addLine(to: pointRight)
            path.close()
            
            UIColor.all.setFill()
            path.fill()
        }
    }
}
