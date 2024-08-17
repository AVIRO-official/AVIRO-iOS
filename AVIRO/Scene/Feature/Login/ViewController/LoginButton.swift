//
//  LoginButton.swift
//  AVIRO
//
//  Created by 전성훈 on 7/1/24.
//

import UIKit

final class LoginButton: UIButton {
    var didTappedButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAttribute() {
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        self.titleLabel?.font = .pretendard(size: 17, weight: .medium)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 26
        self.clipsToBounds = true
        
        self.addTarget(
            self,
            action: #selector(didTappedButton(_:)),
            for: .touchUpInside
        )
    }
    
    func setButtonStyle(type: LoginType) {
        switch type {
        case .apple:
            setTitle("애플 로그인", for: .normal)
            setTitleColor(.white, for: .normal)
            setButtonImage(.appleLogin)
            
            self.layer.borderColor = UIColor.black.cgColor
            self.backgroundColor = .black
        case .google:
            setTitle("구글 로그인", for: .normal)
            setTitleColor(.black, for: .normal)
            setButtonImage(.googleLogin)
            
            self.layer.borderColor = UIColor(hex: "#D5D5D5").cgColor
            self.backgroundColor = .white
        case .kakao:
            setTitle("카카오 로그인", for: .normal)
            setTitleColor(.black, for: .normal)
            setButtonImage(.kakaoLogin)
            
            self.layer.borderColor = UIColor(hex: "#FEE500").cgColor
            self.backgroundColor = UIColor(hex: "#FEE500")
        case .naver:
            setTitle("네이버 로그인", for: .normal)
            setTitleColor(.white, for: .normal)
            setButtonImage(.naverLogin)
            
            self.layer.borderColor = UIColor(hex: "#03C75A").cgColor
            self.backgroundColor = UIColor(hex: "#03C75A")
        }
    }
    
    private func setButtonImage(_ image: UIImage) {
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        setImage(image, for: .selected)
        setImage(image, for: .disabled)
    }
    
    @objc private func didTappedButton(_ sender: UIButton) {
        self.didTappedButton?()
    }
}
