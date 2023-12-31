//
//  MyInfoView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

final class MyInfoView: UIView {
    private lazy var myPlaceLabel: UILabel = {
        let label = UILabel()
        
        label.text = "등록한 가게"
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .semibold)
        
        return label
    }()
    
    private lazy var myPlaceButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("0개", for: .normal)
        button.setTitleColor(.gray0, for: .normal)
        button.titleLabel?.font = .pretendard(size: 20, weight: .bold)
        button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var myPlaceStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center
        
        return stackView
    }()
    
    private lazy var myReviewLabel: UILabel = {
        let label = UILabel()
        
        label.text = "작성 후기"
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .semibold)
        
        return label
    }()

    private lazy var myReviewButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("0개", for: .normal)
        button.setTitleColor(.gray0, for: .normal)
        button.titleLabel?.font = .pretendard(size: 20, weight: .bold)
        button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)

        return button
    }()
    
    private lazy var myReviewStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center

        return stackView
    }()
    
    private lazy var myStarLabel: UILabel = {
        let label = UILabel()
        
        label.text = "즐겨찾기"
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .semibold)
        
        return label
    }()
    
    private lazy var myStarButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("0개", for: .normal)
        button.setTitleColor(.gray0, for: .normal)
        button.titleLabel?.font = .pretendard(size: 20, weight: .bold)
        button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)

        return button
    }()
    
    private lazy var myStarStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center

        return stackView
    }()
    
    private lazy var leftDividerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray5
        
        return view
    }()
    
    private lazy var rightDividerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray5
        
        return view
    }()
    
    private lazy var myStateStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    var tappedCountButton: (() -> Void)?
    
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
            myPlaceLabel,
            myPlaceButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myPlaceStackView.addArrangedSubview($0)
        }
        
        [
            myReviewLabel,
            myReviewButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myReviewStackView.addArrangedSubview($0)
        }
        
        [
            myStarLabel,
            myStarButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myStarStackView.addArrangedSubview($0)
        }
        
        [
            myPlaceStackView,
            leftDividerView,
            myReviewStackView,
            rightDividerView,
            myStarStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myStateStackView.addArrangedSubview($0)
        }
        
        myStateStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(myStateStackView)
        
        NSLayoutConstraint.activate([
            myStateStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            myStateStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            myStateStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            myStateStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            
            leftDividerView.heightAnchor.constraint(equalTo: myStateStackView.heightAnchor, multiplier: 1),
            leftDividerView.widthAnchor.constraint(equalToConstant: 1),
            
            rightDividerView.heightAnchor.constraint(equalTo: myStateStackView.heightAnchor, multiplier: 1),
            rightDividerView.widthAnchor.constraint(equalToConstant: 1),
            
            myPlaceStackView.widthAnchor.constraint(equalToConstant: 100),
            myReviewStackView.widthAnchor.constraint(equalToConstant: 100),
            myStarStackView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    // TODO: DataBinding 설계 시 삭제 예정
    func updateMyPlace(_ place: String) {
        myPlaceButton.setTitle("\(place)개", for: .normal)
    }
    
    func updateMyReview(_ review: String) {
        myReviewButton.setTitle("\(review)개", for: .normal)
    }
    
    func updateMyStar(_ star: String) {
        myStarButton.setTitle("\(star)개", for: .normal)
    }
    
    @objc private func tappedButton(_ sender: UIButton) {
        tappedCountButton?()
    }
}
