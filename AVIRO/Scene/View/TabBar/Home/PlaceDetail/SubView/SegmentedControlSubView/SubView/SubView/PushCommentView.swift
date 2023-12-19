//
//  PushCommentView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/27.
//

import UIKit

final class PushCommentView: UIView {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        
        textView.text = "식당에 대한 경험과 팁을 알려주세요!"
        textView.font = .pretendard(size: 15, weight: .medium)
        textView.textColor = .gray4
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.gray4.cgColor
        textView.layer.borderWidth = 0.5
        
        textView.isEditable = true
        textView.isScrollEnabled = false

        textView.backgroundColor = .gray7
        textView.delegate = self

        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.lineFragmentPadding = 0
   
        return textView
    }()
    
    private lazy var enrollButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("등록", for: .normal)
        button.setTitleColor(.gray4, for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.addTarget(self, action: #selector(enrollButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var separator: UIView = {
       let separator = UIView()
        
        separator.backgroundColor = .gray3
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return separator
    }()
    
    private lazy var cancelEditButton: UIButton = {
        let button = UIButton()
       
        button.setImage(UIImage(named: "Close"), for: .normal)
        button.addTarget(self, action: #selector(cancelEditTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var viewHeight: NSLayoutConstraint?
    
    private var temparyTextViewHeightConstraint: NSLayoutConstraint?
    private var textViewLeadingWhenHiddenCancelButton: NSLayoutConstraint?
    private var textViewLeadingWhenShowCancelButton: NSLayoutConstraint?
    
    var enrollReview: ((String) -> Void)?
    var initView: (() -> Void)?
    
    var test: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        makeViewHeight()
    }
    
    private func setupLayout() {
        [
            separator,
            textView,
            enrollButton,
            cancelEditButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        viewHeight = heightAnchor.constraint(equalToConstant: 0)
        viewHeight?.isActive = true
        
        textViewLeadingWhenHiddenCancelButton = textView.leadingAnchor.constraint(
            equalTo: self.leadingAnchor, constant: 10
        )
        textViewLeadingWhenHiddenCancelButton?.isActive = true
        
        textViewLeadingWhenShowCancelButton = textView.leadingAnchor.constraint(
            equalTo: cancelEditButton.trailingAnchor, constant: 10
        )
        textViewLeadingWhenShowCancelButton?.isActive = false
        
        temparyTextViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 34)
        temparyTextViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(
                equalTo: self.topAnchor),
            separator.leadingAnchor.constraint(
                equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(
                equalTo: self.trailingAnchor),
            
            textView.topAnchor.constraint(
                equalTo: separator.bottomAnchor, constant: 12.5),
            textView.trailingAnchor.constraint(
                equalTo: enrollButton.leadingAnchor, constant: -10),
            
            cancelEditButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cancelEditButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            cancelEditButton.widthAnchor.constraint(equalToConstant: 15),
            cancelEditButton.heightAnchor.constraint(equalToConstant: 15),
            
            enrollButton.centerYAnchor.constraint(
                equalTo: self.centerYAnchor),
            enrollButton.trailingAnchor.constraint(
                equalTo: self.trailingAnchor, constant: -16),
            enrollButton.widthAnchor.constraint(equalToConstant: 32),
            enrollButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
        cancelEditButton.isHidden = true
    }
    
    private func makeViewHeight() {
        let separatorHeight = separator.frame.height
        let textView = textView.frame.height

        let inset: CGFloat = 25
        
        viewHeight?.constant = separatorHeight + textView + inset
    }
    
    @objc private func enrollButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.textColor == .gray0 {
            guard let text = textView.text else { return }
            enrollReview?(text)

            initTextViewWhenAfterEditReview()
            
            self.endEditing(true)
        } else {
            return
        }
    }
    
    @objc private func cancelEditTapped() {
        initTextViewWhenAfterEditReview()
    }
    
    func autoStartWriteComment() {
        textView.becomeFirstResponder()
    }
    
    func editMyReview(_ text: String) {
        textView.text = text
        textView.textColor = .gray0
        enrollButton.setTitleColor(.gray0, for: .normal)
        
        whenEditUpdateTextViewHeight()
        updateViewWhenEditComment(true)
        textView.becomeFirstResponder()
    }
    
    func initTextViewWhenAfterEditReview() {
        textView.isScrollEnabled = false
        textView.resignFirstResponder()
        
        initAttribute()
        updateTextviewHeight()
        updateViewWhenEditComment(false)
        
        initView?()
    }
    
    private func initTextViewWhenAfterEnrollReview() {
        initAttribute()
        temparyTextViewHeightConstraint?.constant = CGFloat(34)
        textView.resignFirstResponder()
    }
    
    private func initAttribute() {
        textView.text = "식당에 대한 경험과 팁을 알려주세요!"
        textView.textColor = .gray4
        enrollButton.setTitleColor(.gray4, for: .normal)
    }
    
    private func updateViewWhenEditComment(_ isShow: Bool) {
        cancelEditButton.isHidden = !isShow
        
        if isShow {
            textViewLeadingWhenHiddenCancelButton?.isActive = false
            textViewLeadingWhenShowCancelButton?.isActive = true
        } else {
            textViewLeadingWhenShowCancelButton?.isActive = false
            textViewLeadingWhenHiddenCancelButton?.isActive = true
        }
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateTextviewHeight() {
        temparyTextViewHeightConstraint?.isActive = false

        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let maxLines = 5
        let maxHeight = textView.font!.lineHeight * CGFloat(maxLines)
        
        if estimatedSize.height <= maxHeight {
            textView.isScrollEnabled = false
        } else {
            temparyTextViewHeightConstraint?.constant = maxHeight
            temparyTextViewHeightConstraint?.isActive = true
            textView.isScrollEnabled = true
        }
    }
    
    private func whenEditUpdateTextViewHeight() {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let maxLines = 5
        let maxHeight = textView.font!.lineHeight * CGFloat(maxLines)

        if estimatedSize.height <= maxHeight {
            textView.isScrollEnabled = false
        } else {
            temparyTextViewHeightConstraint?.constant = maxHeight
            temparyTextViewHeightConstraint?.isActive = true
            textView.isScrollEnabled = true
        }
    }
    
    // MARK: Keyboard Method 처리
    func keyboardWillShow(notification: NSNotification, height: CGFloat) {
        if let userInfo = notification.userInfo {
            let animationDuration = (userInfo[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? NSNumber)?
                .doubleValue ?? 0.25

            let animationCurveRaw = (userInfo[
                UIResponder.keyboardAnimationCurveUserInfoKey
            ] as? NSNumber)?
                .uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue

            let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

            UIView.animate(
                withDuration: animationDuration,
                delay: 0.023,
                options: animationCurve, animations: {
                    self.transform = CGAffineTransform(
                        translationX: 0,
                        y: -height
                    )
                },
                completion: nil
            )
        }
    }
    
    func keyboardWillHide() {
        UIView.performWithoutAnimation {
            self.transform = .identity
        }
    }
}


// TODO: 수정 예정
// - View로 만들자 textview기능 다 삭제
// - 폴더 정리
// 클릭 후 editing 종료 해야함
extension PushCommentView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
//        let vc = ReviewWriteViewController()
//        if textView.textColor == .gray4 {
//            textView.textColor = .gray0
//            textView.text = ""
//        }
        
        test?()
        textView.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        if textView.text != "" {
//            enrollButton.setTitleColor(.gray0, for: .normal)
//            updateTextviewHeight()
//        } else {
//            enrollButton.setTitleColor(.gray4, for: .normal)
//        }
    }
}
