//
//  ReviewPushView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/21.
//

import UIKit

final class ReviewPushView: UIView {
    private lazy var textFieldView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.gray4.cgColor
        view.layer.borderWidth = 0.5
        
        view.backgroundColor = .gray7
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var enrollLabel: UILabel = {
        let label = UILabel()
        
        label.text = "등록"
        label.textColor = .gray4
        label.font = .pretendard(size: 17, weight: .semibold)
        
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray3
        
        return view
    }()
    
    var pushReviewWriteView: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            textFieldView,
            enrollLabel,
            separator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: self.topAnchor),
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            textFieldView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12.5),
            textFieldView.trailingAnchor.constraint(equalTo: enrollLabel.leadingAnchor, constant: -22.5),
            textFieldView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            textFieldView.heightAnchor.constraint(equalToConstant: 34),
            
            enrollLabel.centerYAnchor.constraint(equalTo: textFieldView.centerYAnchor),
            enrollLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    @objc private func textFieldTapped(_ sender: UITapGestureRecognizer) {
        pushReviewWriteView?()
    }
}
