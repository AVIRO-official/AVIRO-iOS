//
//  PlaceReviewTableViewCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/17.
//

import UIKit

final class PlaceReviewTableViewCell: UITableViewCell {
    static let identifier = "PlaceReviewTableViewCell"
    
    private lazy var nickname: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 16, weight: .semibold)
        label.textColor = .gray0
        
        return label
    }()
    
    private lazy var createdTime: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 13, weight: .regular)
        label.textColor = .gray2
        
        return label
    }()
    
    private lazy var topLabelStack: UIStackView = {
        let stackView = UIStackView()
        
        stackView.spacing = 7
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        return stackView
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(named: "Dots"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        
        return stackView
    }()
    
    private lazy var reviewBackgroundView: UIView = {
        let view = UIView()
       
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        
        return view
    }()
    
    private lazy var review: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private var commentId = ""
    
    var reportButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeLayout() {
        [
            nickname,
            createdTime
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            topLabelStack.addArrangedSubview($0)
        }
        
        [
            topLabelStack,
            reportButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            topStackView.addArrangedSubview($0)
        }
        
        [
            topStackView,
            reviewBackgroundView,
            review
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(
                equalTo: self.contentView.topAnchor, constant: 0),
            topStackView.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor),
            topStackView.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor),
            
            reviewBackgroundView.topAnchor.constraint(
                equalTo: topLabelStack.bottomAnchor, constant: 10),
            reviewBackgroundView.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor),
            reviewBackgroundView.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor),
            reviewBackgroundView.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor, constant: -15),
            
            review.topAnchor.constraint(
                equalTo: reviewBackgroundView.topAnchor, constant: 12),
            review.leadingAnchor.constraint(
                equalTo: reviewBackgroundView.leadingAnchor, constant: 16),
            review.trailingAnchor.constraint(
                equalTo: reviewBackgroundView.trailingAnchor, constant: -16),
            review.bottomAnchor.constraint(
                equalTo: reviewBackgroundView.bottomAnchor, constant: -12)
        ])
    }
    
    func bindingData(comment: AVIROReviewRawData,
                     isAbbreviated: Bool,
                     isMyReview: Bool
    ) {
        commentId = comment.commentId
        nickname.text = comment.nickname
        createdTime.text = comment.updatedTime

        setLabelAttribute(text: comment.content, isAbbreviated: isAbbreviated, isMyReview: isMyReview)
    }
    
    private func setLabelAttribute(
        text: String,
        isAbbreviated: Bool,
        isMyReview: Bool
    ) {
        review.text = text
        changeReviewColor(isMyReview: isMyReview)
        changeReviewAbbreviated(isAbbreviated: isAbbreviated)
    }
    
    private func changeReviewColor(isMyReview: Bool) {
        review.font = isMyReview ? 
            .pretendard(size: 15, weight: .semibold) :
            .pretendard(size: 15, weight: .medium)
        
        review.textColor = isMyReview ? .main : .gray0
        reviewBackgroundView.backgroundColor = isMyReview ? .bgNavy : .gray6
    }
    
    private func changeReviewAbbreviated(isAbbreviated: Bool) {
        review.lineBreakMode = isAbbreviated ? .byTruncatingTail : .byWordWrapping
        review.numberOfLines = isAbbreviated ? 4 : 0
    }
    
    // MARK: UpLoad 전 수정 -> nickname 수정 후
    @objc private func buttonTapped() {
        reportButtonTapped?()
    }
}
