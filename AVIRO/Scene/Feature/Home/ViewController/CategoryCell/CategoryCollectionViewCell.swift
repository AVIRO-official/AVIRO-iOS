//
//  CategoryCollectionViewCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/02/17.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = CategoryCollectionViewCell.description()
    
    private lazy var categoryButton: UIButton = {
        let btn = UIButton()
       
        btn.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        btn.contentMode = .scaleAspectFill
        btn.layer.shadowColor = UIColor.gray5.cgColor
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowOffset = CGSize(width: 1, height: 1)
        btn.imageView?.contentMode = .scaleAspectFit

        return btn
    }()
    
    private var type = ""
    var whenCategoryButtonTapped: ((String, Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        type = ""
        categoryButton.isSelected = false
        categoryButton.setImage(nil, for: .normal)
        categoryButton.setImage(nil, for: .selected)
    }
    
    private func setupLayout() {
        [
            categoryButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            categoryButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            categoryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
    }
    
    func configure(with type: String, state: Bool) {
        self.type = type
        setupButtonImage(with: type)
        
        if type == "취소" {
            setupCancelButtonState(with: state)
        } else {
            setupCategoryButtonState(with: state)
        }
    }
    
    private func setupButtonImage(with type: String) {
        switch type {
        case "식당":
            categoryButton.setImage(UIImage.defaultCategoryRestaurant, for: .normal)
            categoryButton.setImage(UIImage.onCategoryRestaurant, for: .selected)
        case "카페":
            categoryButton.setImage(UIImage.defaultCategoryCoffee, for: .normal)
            categoryButton.setImage(UIImage.onCategoryCoffee, for: .selected)
        case "술집":
            categoryButton.setImage(UIImage.defaultCategoryBar, for: .normal)
            categoryButton.setImage(UIImage.onCategoryBar, for: .selected)
        case "빵집":
            categoryButton.setImage(UIImage.defaultCategoryBread, for: .normal)
            categoryButton.setImage(UIImage.onCategoryBread, for: .selected)
        default:
            categoryButton.setImage(UIImage.cancelCategory, for: .normal)
        }
    }
    
    private func setupCategoryButtonState(with isSelected: Bool) {
        categoryButton.isHidden = false
        categoryButton.isSelected = isSelected
    }
    
    private func setupCancelButtonState(with isHidden: Bool) {
        categoryButton.isSelected = false
        categoryButton.isHidden = isHidden
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if type == "취소" {
            whenCategoryButtonTapped?(type, !sender.isSelected)
        } else {
            whenCategoryButtonTapped?(type, sender.isSelected)
        }
    }
}
