//
//  PlaceDeleteRequestView.swift
//  AVIRO
//
//  Created by 전성훈 on 6/16/24.
//

import UIKit

final class PlaceDeleteRequestView: UIView {
    private lazy var deleteRequestButton: EditInfoButton = {
        let button = EditInfoButton()
        
        button.setButton("가게 삭제 요청하기")
        button.tintColor = .warning
        button.setTitleColor(.warning, for: .normal)
        button.addTarget(
            self,
            action: #selector(editButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private var viewHeightConstraint: NSLayoutConstraint?
    var deleteRequestButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        [
            deleteRequestButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        viewHeightConstraint = self.heightAnchor.constraint(equalToConstant: 60)
        viewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            deleteRequestButton.widthAnchor.constraint(equalToConstant: 130),
            deleteRequestButton.heightAnchor.constraint(equalToConstant: 20),
            deleteRequestButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            deleteRequestButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            deleteRequestButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    @objc private func editButtonTapped(_ sender: UIButton) {
        deleteRequestButtonTapped?()
    }
}
