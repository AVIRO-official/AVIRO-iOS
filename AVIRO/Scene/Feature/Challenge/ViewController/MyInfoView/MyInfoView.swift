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
    
    private lazy var myPlaceCountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "0개"
        lbl.textColor = .gray0
        lbl.font = .pretendard(size: 20, weight: .bold)
        
        return lbl
    }()
    
    private lazy var myPlaceStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.tag = 0
        
        return stackView
    }()
    
    private lazy var myReviewLabel: UILabel = {
        let label = UILabel()
        
        label.text = "작성 후기"
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .semibold)
        
        return label
    }()

    private lazy var myReviewCountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "0개"
        lbl.textColor = .gray0
        lbl.font = .pretendard(size: 20, weight: .bold)
        
        return lbl
    }()

    private lazy var myReviewStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.tag = 1

        return stackView
    }()
    
    private lazy var myStarLabel: UILabel = {
        let label = UILabel()
        
        label.text = "즐겨찾기"
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .semibold)
        
        return label
    }()
    
    private lazy var myStarCountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "0개"
        lbl.textColor = .gray0
        lbl.font = .pretendard(size: 20, weight: .bold)
        
        return lbl
    }()
    
    private lazy var myStarStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.tag = 2
        
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

    var tappedMyInfo: ((MyInfoType) -> Void)?
    
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
            myPlaceCountLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myPlaceStackView.addArrangedSubview($0)
        }
        
        [
            myReviewLabel,
            myReviewCountLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myReviewStackView.addArrangedSubview($0)
        }
        
        [
            myStarLabel,
            myStarCountLabel
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
        
        [
            myStateStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
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
        
        addTapGestureToStackView()
    }
    
    private func addTapGestureToStackView() {
        let myPlaceTapGesture = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped(_:)))
        myPlaceStackView.addGestureRecognizer(myPlaceTapGesture)
        myPlaceStackView.isUserInteractionEnabled = true

        let myReviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped(_:)))
        myReviewStackView.addGestureRecognizer(myReviewTapGesture)
        myReviewStackView.isUserInteractionEnabled = true

        let myStarTapGesture = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped(_:)))
        myStarStackView.addGestureRecognizer(myStarTapGesture)
        myStarStackView.isUserInteractionEnabled = true
    }

    @objc private func stackViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let stackView = gesture.view as? UIStackView else { return }
        
        switch stackView.tag {
        case 0:
            tappedMyInfo?(.place)
        case 1:
            tappedMyInfo?(.review)
        case 2:
            tappedMyInfo?(.bookmark)
        default:
            break
        }
    }
    
    func updateMyPlace(_ place: String) {
        myPlaceCountLabel.text = "\(place)개"
    }
    
    func updateMyReview(_ review: String) {
        myReviewCountLabel.text = "\(review)개"
    }
    
    func updateMyStar(_ star: String) {
        myStarCountLabel.text = "\(star)개"
    }
}
