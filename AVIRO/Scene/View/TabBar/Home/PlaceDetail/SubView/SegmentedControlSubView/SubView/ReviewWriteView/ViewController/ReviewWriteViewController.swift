//
//  ReviewWriteViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//

import UIKit

final class ReviewWriteViewController: UIViewController {
    private lazy var placeInfoView: ReviewPlaceInfoView = {
        let view = ReviewPlaceInfoView()
        
        view.backgroundColor = .red
        
        return view
    }()
    
    private lazy var reviewTextView: UITextView = {
        let view = UITextView()
        
        view.textColor = .gray0
        view.font = .pretendard(size: 16, weight: .regular)
        view.backgroundColor = .gray6
        view.layer.cornerRadius = 10
        view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "욕설, 비방 등 사장님과 다른 사용자들을 불쾌하게 하는 내용은 남기지 말아주세요."
        label.textColor = .gray5
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.font = .pretendard(size: 16, weight: .regular)
        label.isHidden = !reviewTextView.text.isEmpty
        
        return label
    }()
    
    private lazy var textViewCountLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "맛, 가격, 분위기, 편의시설, 비건프렌들리함 등"
        label.textColor = .gray2
        label.numberOfLines = 1
        label.font = .pretendard(size: 16, weight: .medium)
        
        return label
    }()
    
    private lazy var exampleSticy: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var reviewUploadButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    private func setupLayout() {
        [
            placeInfoView,
            reviewTextView,
            placeholderLabel,
            textViewCountLabel,
            exampleLabel,
            exampleSticy,
            reviewUploadButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // TODO: placeInfoVIew 높이는 값에 따라 동적으로 다르게 설정
            placeInfoView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            placeInfoView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeInfoView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeInfoView.heightAnchor.constraint(equalToConstant: 90),

            reviewTextView.topAnchor.constraint(equalTo: placeInfoView.bottomAnchor, constant: 20),
            reviewTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            reviewTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            reviewTextView.heightAnchor.constraint(equalToConstant: 320),
            
            placeholderLabel.topAnchor.constraint(equalTo: reviewTextView.topAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: reviewTextView.leadingAnchor, constant: 20),
            placeholderLabel.trailingAnchor.constraint(equalTo: reviewTextView.trailingAnchor, constant: -20),
            
            textViewCountLabel.bottomAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: -16),
            textViewCountLabel.trailingAnchor.constraint(equalTo: reviewTextView.trailingAnchor, constant: -16),
            
            exampleLabel.topAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: 16),
            exampleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            
            exampleSticy.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            exampleSticy.bottomAnchor.constraint(equalTo: reviewUploadButton.topAnchor, constant: -11),
            
            reviewUploadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            reviewUploadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            reviewUploadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            reviewUploadButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAttribute() {
        navigationController?.navigationBar.isHidden = false

        self.view.backgroundColor = .gray7
        self.navigationItem.title = "후기 작성"
        self.setupBack(true)
    }
}
