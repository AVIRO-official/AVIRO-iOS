//
//  MyBookmarkListTableViewCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

import UIKit

final class MyBookmarkListTableViewCell: UITableViewCell {
    static let identifier = MyBookmarkListTableViewCell.description()
        
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 10.3
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var categoryLabel: UILabel = {
        let lbl = UILabel()
       
        lbl.textAlignment = .center
        lbl.font = .pretendard(size: 14, weight: .bold)
        lbl.numberOfLines = 1
        lbl.layer.cornerRadius = 7.5
        lbl.backgroundColor = .gray5
        lbl.textColor = .white
        lbl.clipsToBounds = true
        
        return lbl
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 20, weight: .bold)
        lbl.numberOfLines = 1
        lbl.textColor = .gray0
        
        return lbl
    }()
    
    private lazy var starButton: UIButton = {
        let btn = UIButton()
        
        btn.setImage(.starIconDisable.withTintColor(.gray4), for: .normal)
        btn.setImage(.starIconClicked, for: .selected)
        btn.addTarget(self, action: #selector(tappedStarButton(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var addressLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 16, weight: .medium)
        lbl.numberOfLines = 1
        lbl.textColor = .gray0
        
        return lbl
    }()
    
    private lazy var menuLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 16, weight: .regular)
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        lbl.textColor = .gray3
        
        return lbl
    }()
    
    private lazy var menuCountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 16, weight: .regular)
        lbl.numberOfLines = 1
        lbl.textColor = .gray3
        
        return lbl
    }()
    
    private lazy var enrollTimeLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 14, weight: .regular)
        lbl.numberOfLines = 1
        lbl.textColor = .gray3
        
        return lbl
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
       
        view.backgroundColor = .gray6
        
        return view
    }()
    
    var onStarButtonTapped: (() -> Void)?
    var onTouchRelease: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        self.animateTouchResponse(isTouchDown: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // 애니메이션 진행 중일 경우 완료 후 onTouchRelease 호출
        if self.isAnimating {
            self.animateTouchResponse(isTouchDown: false) { [weak self] in
                self?.onTouchRelease?()
            }
        } else {
            animateTouchResponse(isTouchDown: false) { [weak self] in
                self?.onTouchRelease?()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        self.animateTouchResponse(isTouchDown: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        initConfiguration()
    }
    
    private func setupLayout() {
        [
            mainView,
            separatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            mainView.heightAnchor.constraint(equalToConstant: 130),
            
            separatorView.topAnchor.constraint(equalTo: mainView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        [
            iconImageView,
            categoryLabel,
            titleLabel,
            starButton,
            addressLabel,
            menuLabel,
            menuCountLabel,
            enrollTimeLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            mainView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 59),
            iconImageView.heightAnchor.constraint(equalToConstant: 59),
            
            categoryLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4.5),
            categoryLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            categoryLabel.heightAnchor.constraint(equalToConstant: 26.5),
            categoryLabel.widthAnchor.constraint(equalToConstant: 59),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -14),
            
            starButton.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            starButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            starButton.widthAnchor.constraint(equalToConstant: 24),
            starButton.heightAnchor.constraint(equalToConstant: 24),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            addressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            menuLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 3),
            menuLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            menuLabel.trailingAnchor.constraint(equalTo: menuCountLabel.leadingAnchor, constant: -4),
            
            menuCountLabel.topAnchor.constraint(equalTo: menuLabel.topAnchor),
            menuCountLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: mainView.trailingAnchor,
                constant: -14),
            menuCountLabel.widthAnchor.constraint(equalToConstant: 78),
            
            enrollTimeLabel.topAnchor.constraint(equalTo: menuLabel.bottomAnchor, constant: 3),
            enrollTimeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            enrollTimeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
    }
    
    private func initConfiguration() {
        iconImageView.image = nil
        categoryLabel.text = ""
        categoryLabel.backgroundColor = .clear
        
        titleLabel.text = ""
        addressLabel.text = ""
        
        menuLabel.text = ""
        menuCountLabel.text = ""
        
        enrollTimeLabel.text = ""
        starButton.isSelected = true
    }
    
    // TODO: - 변경 예정
    @objc private func tappedStarButton(_ sender: UIButton) {
        starButton.isSelected.toggle()
        
        onStarButtonTapped?()
    }
    
    // TODO: - 변경 예정
    func configuration(with model: MyBookmarkCellModel) {
        switch model.veganType {
        case .All:
            switch model.category {
            case .Bar:
                iconImageView.image = .allBoxBar
            case .Bread:
                iconImageView.image = .allBoxBread
            case .Coffee:
                iconImageView.image = .allBoxCoffee
            case .Restaurant:
                iconImageView.image = .allBoxRestaurant
            }
            categoryLabel.backgroundColor = .all

        case .Some:
            switch model.category {
            case .Bar:
                iconImageView.image = .someBoxBar
            case .Bread:
                iconImageView.image = .someBoxBread
            case .Coffee:
                iconImageView.image = .someBoxCoffee
            case .Restaurant:
                iconImageView.image = .someBoxRestaurant
            }
            categoryLabel.backgroundColor = .some

        case .Request:
            switch model.category {
            case .Bar:
                iconImageView.image = .requestBoxBar
            case .Bread:
                iconImageView.image = .requestBoxBread
            case .Coffee:
                iconImageView.image = .requestBoxCoffee
            case .Restaurant:
                iconImageView.image = .requestBoxRestaurant
            }
            categoryLabel.backgroundColor = .request
        }
        
        categoryLabel.text = model.category.title

        titleLabel.text = model.title
        addressLabel.text = model.address
        menuLabel.text = model.menu
        
        if model.menuCount > 0 {
            menuCountLabel.text = "외 " + String(model.menuCount) + "개 메뉴"
        }
        
        enrollTimeLabel.text = model.createdBefore
        starButton.isSelected = model.isStar
    }
}
