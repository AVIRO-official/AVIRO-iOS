//
//  MyInfoListHeaderView.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/05.
//

import UIKit

final class MyInfoListHeaderView: UITableViewHeaderFooterView {
    static let identifier = MyInfoListHeaderView.description()
    
    private lazy var countLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.numberOfLines = 1
        lbl.font = .pretendard(size: 18, weight: .semibold)
        lbl.textColor = .gray0
        
        return lbl
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            countLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 48),
            countLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            countLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
    }
    
    func configuration(with count: Int) {
        countLabel.text = "총 \(count)개의 가게"
    }
}
