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
        
        return btn
    }()
    
    private var type = ""
    var whenTappedCategoryButtonTapped: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
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
    
    func configure(with type: String) {
        self.type = type
        switch type {
        case "식당":
            categoryButton.setImage(UIImage.defaultCategoryRestaurant, for: .normal)
            categoryButton.setImage(UIImage.onCategoryRestaurant, for: .selected)

            categoryButton.imageView?.contentMode = .scaleAspectFit
        case "카페":
            categoryButton.setImage(UIImage.defaultCategoryCoffee, for: .normal)
            categoryButton.setImage(UIImage.onCategoryCoffee, for: .selected)
            
            categoryButton.imageView?.contentMode = .scaleAspectFit
        case "술집":
            categoryButton.setImage(UIImage.defaultCategoryBar, for: .normal)
            categoryButton.setImage(UIImage.onCategoryBar, for: .selected)
            
            categoryButton.imageView?.contentMode = .scaleAspectFit
        case "빵집":
            categoryButton.setImage(UIImage.defaultCategoryBread, for: .normal)
            categoryButton.setImage(UIImage.onCategoryBread, for: .selected)
            
            categoryButton.imageView?.contentMode = .scaleAspectFit

        case "취소":
            categoryButton.setImage(UIImage.cancelCategory, for: .normal)
            categoryButton.imageView?.contentMode = .scaleAspectFit

        default:
            categoryButton.setImage(UIImage.cancelCategory, for: .normal)
            
            categoryButton.imageView?.contentMode = .scaleAspectFit

        }
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        whenTappedCategoryButtonTapped?(type)
    }
}
