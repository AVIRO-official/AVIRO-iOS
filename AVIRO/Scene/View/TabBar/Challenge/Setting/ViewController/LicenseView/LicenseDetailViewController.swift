//
//  LicenseDetailViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//

import UIKit

final class LicenseDetailViewController: UIViewController {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        
        textView.isEditable = false
        textView.font = .pretendard(size: 14, weight: .medium)
        textView.textColor = .gray0
        textView.backgroundColor = .gray6
        textView.layer.cornerRadius = 10
        
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupAttribute()
    }
    
    private func setupLayout() {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .gray7
        self.setupBack()
    }

    func loadLicenseText(with body: String, title: String) {
        textView.text = body
        self.navigationItem.title = title
    }
}
