//
//  FranchiseToggleButton.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/02/23.
//

// MARK: - Toggle button Custom Refectoring 필요
// TODO: 좀 더 외부에서 프로퍼티 값을 받을 수 있도록 수정 예정
import UIKit

final class FranchiseToggleButton: UIView {
    var isSelected: Bool = false {
        didSet {
            updateLayoutForState()
        }
    }

    private lazy var title: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "프랜차이즈"
        lbl.numberOfLines = 1
        lbl.textColor = .gray3
        lbl.font = UIFont.pretendard(size: 14.4, weight: .medium)
        
        return lbl
    }()
    
    private lazy var buttonSwitch: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 26/2
        view.backgroundColor = .gray7
        
        return view
    }()

    private var switchLeadingConstraint: NSLayoutConstraint?
    private var switchTrailingConstraint: NSLayoutConstraint?
    
    private var titleLeadingConstraint: NSLayoutConstraint?
    private var titleTrailingConstarint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupLayout()
        setupAttribute()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            title,
            buttonSwitch
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        switchLeadingConstraint = buttonSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4)
        switchLeadingConstraint?.isActive = true
        
        switchTrailingConstraint = buttonSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)
        switchTrailingConstraint?.isActive = false
        
        titleTrailingConstarint = title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -9)
        titleTrailingConstarint?.isActive = true
        
        titleLeadingConstraint = title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9)
        titleLeadingConstraint?.isActive = false
        
        NSLayoutConstraint.activate([
            buttonSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonSwitch.widthAnchor.constraint(equalToConstant: 26),
            buttonSwitch.heightAnchor.constraint(equalToConstant: 26),
            
            title.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = UIColor(hex: "#F7F7F8")
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggle))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggle() {
        isSelected.toggle()
    }
    
    private func updateLayoutForState() {
        UIView.animate(withDuration: 0.4) {
            if self.isSelected {
                self.switchLeadingConstraint?.isActive = false
  
                self.switchTrailingConstraint?.isActive = true

                self.titleTrailingConstarint?.isActive = false
                self.titleLeadingConstraint?.isActive = true
                
                self.title.textColor = .gray7
                self.backgroundColor = .keywordBlue
                
            } else {
                self.switchTrailingConstraint?.isActive = false
                self.switchLeadingConstraint?.isActive = true

                self.titleLeadingConstraint?.isActive = false
                self.titleTrailingConstarint?.isActive = true
                
                self.title.textColor = .gray3
                self.backgroundColor = .gray6
            }
            self.layoutIfNeeded()
        }
    }
}
