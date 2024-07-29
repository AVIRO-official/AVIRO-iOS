//
//  EnrollField.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/22.
//

import UIKit

class EnrollField: UITextField {
    private var horizontalPadding: CGFloat = 16
    private var verticalPadding: CGFloat = 13
    private var imageViewSize: CGFloat = 24
    private var buttonSize: CGFloat = 24
    private var buttonPadding: CGFloat = 7

    private var isAddLeftImage = false
    private var isAddRightButton = false
    
    private var rightButton = UIButton()
    
    var tappedPushViewButton: (() -> Void)?
    
    var rightButtonHidden = false {
        didSet {
            rightView?.isHidden = rightButtonHidden
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configuration()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func textRect(
        forBounds bounds: CGRect
    ) -> CGRect {
        let inset = setTextInset()
            
        return bounds.inset(by: inset)
    }
    
    override func editingRect(
        forBounds bounds: CGRect
    ) -> CGRect {
        let inset = setTextInset()
        
        return bounds.inset(by: inset)
    }
    
    private func configuration() {
        self.textColor = .gray0
        self.font = .pretendard(size: 16, weight: .medium)
        self.backgroundColor = .gray6
        self.layer.cornerRadius = 10
    }
    
    private func setTextInset() -> UIEdgeInsets {
        var inset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
        
        if isAddLeftImage {
            let leftInest = horizontalPadding + imageViewSize + buttonPadding
            
            inset.left = leftInest
        }
        
        if isAddRightButton {
            let rightInset = horizontalPadding + buttonSize + buttonPadding
            
            inset.right = rightInset
        }
        
        return inset
    }

    func addLeftImage() {
        isAddLeftImage = !isAddLeftImage
        
        let image = UIImage.searchIcon
        
        image.withTintColor(.gray2)
            
        let imageView = UIImageView(image: image)
        
        imageView.frame = CGRect(
            x: horizontalPadding,
            y: 0,
            width: imageViewSize,
            height: imageViewSize
        )
        
        let paddingWidth = horizontalPadding + buttonPadding + imageViewSize
        
        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: paddingWidth,
            height: imageViewSize)
        )
        
        paddingView.addSubview(imageView)
            
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func addRightPushViewControllerButton() {
        isAddRightButton = !isAddRightButton
        
        let image = UIImage.pushView
        
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.frame = CGRect(
            x: 0,
            y: 0,
            width: buttonSize,
            height: buttonSize
        )
        button.addTarget(
            self,
            action: #selector(rightPushViewButtonTapped),
            for: .touchUpInside
        )
        
        let paddingWidth = horizontalPadding + buttonPadding + buttonSize
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: paddingWidth,
                height: buttonSize
            )
        )
        
        paddingView.addSubview(button)
        
        self.rightView = paddingView
        self.rightViewMode = .always
    }

    @objc private func rightPushViewButtonTapped() {
        tappedPushViewButton?()
    }
    
    func addRightCancelButton() {
        let image = UIImage.closeCircle.withRenderingMode(.alwaysTemplate)
        
        rightButton.setImage(image, for: .normal)
        rightButton.tintColor = .gray2
        rightButton.frame = .init(
            x: horizontalPadding,
            y: 0,
            width: buttonSize,
            height: buttonSize
        )
        rightButton.addTarget(
            self,
            action: #selector(rightButtonTapped),
            for: .touchUpInside
        )
        
        let paddingWidth = horizontalPadding + buttonPadding + buttonSize
        
        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: paddingWidth,
            height: buttonSize)
        )
        
        paddingView.addSubview(rightButton)
        
        rightView = paddingView
        rightViewMode = .always
    }
    
    @objc func rightButtonTapped(_ sender: UIButton) {
        self.text = ""
        self.rightButtonHidden = true
    }
    
    func makePlaceHolder(_ placeHolder: String) {
        self.attributedPlaceholder = NSAttributedString(
            string: placeHolder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray3]
        )
    }
    
    func makeShadow(
        color: UIColor = .black,
        radious: CGFloat = 5,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 1, height: 3)
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radious
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
    }
}
