//
//  NickNameChangebleViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/08.
//

import UIKit

private enum Text: String {
    case error = "에러"
}

final class NickNameChangebleViewController: UIViewController {
    lazy var presenter = NickNameChangeblePresenter(viewController: self)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "오랜만이에요\n닉네임을 수정해주세요."
        label.textColor = .main
        label.font = .pretendard(size: 24, weight: .bold)
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
       
        label.text = "어비로에서 불릴 닉네임이에요."
        label.textColor = .gray1
        label.font = .pretendard(size: 14, weight: .regular)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var nicNameField: RegistrationField = {
        let field = RegistrationField()
        
        field.text = MyData.my.nickname
        field.addRightCancelButton()
        
        return field
    }()
    
    private lazy var subInfo: UILabel = {
        let label = UILabel()
        
        label.text = "이모지, 특수문자(-, _ 제외)를 사용할 수 없습니다."
        label.font = .pretendard(size: 13, weight: .regular)
        label.textColor = .gray2
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        
        return label
    }()
    
    private lazy var subInfo2: UILabel = {
        let label = UILabel()
        
        let nickNameCount = MyData.my.nickname.count
        
        label.text = "(\(nickNameCount)/8)"
        label.font = .pretendard(size: 13, weight: .regular)
        label.textColor = .gray2
        label.textAlignment = .right
        
        return label
    }()
    
    private lazy var editNickNameButton: NextPageButton = {
        let button = NextPageButton()
        
        button.setTitle("수정하기", for: .normal)
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(editNicknameButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var tapGesture = UITapGestureRecognizer()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

extension NickNameChangebleViewController: NickNameChangebleProtocol {
    func setupLayout() {
        [
            titleLabel,
            subtitleLabel,
            nicNameField,
            subInfo,
            subInfo2,
            editNickNameButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate( [
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            
            nicNameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            nicNameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            nicNameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            // subInfo
            subInfo.topAnchor.constraint(
                equalTo: nicNameField.bottomAnchor, constant: 10),
            subInfo.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 40),
            subInfo.trailingAnchor.constraint(equalTo: subInfo2.leadingAnchor, constant: -10),
            
            // subInfo2
            subInfo2.topAnchor.constraint(
                equalTo: subInfo.topAnchor),
            subInfo2.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -40),
            subInfo2.widthAnchor.constraint(equalToConstant: 50),
            
            // editButtton
            editNickNameButton.topAnchor.constraint(equalTo: subInfo.bottomAnchor, constant: 30),
            editNickNameButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            editNickNameButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupAttribute() {
        self.view.backgroundColor = .gray7
        self.setupBack(true)
        
        self.navigationItem.title = "닉네임 수정"
        
        nicNameField.delegate = self
    }
    
    func setupGesture() {
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func changeSubInfo(subInfo: String, isVaild: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.subInfo.text = subInfo
            
            if isVaild {
                self?.editNickNameButton.isEnabled = true
                self?.nicNameField.isPossible = true
                self?.subInfo.textColor = .gray2
            } else {
                self?.editNickNameButton.isEnabled = false
                self?.nicNameField.isPossible = false
                self?.subInfo.textColor = .red
                self?.nicNameField.activeHshakeEffect()
            }

        }
    }
    
    func initSubInfo() {
        self.subInfo.text = "이모지, 특수문자(-, _ 제외)를 사용할 수 없습니다."
        self.subInfo.textColor = .gray2
        self.editNickNameButton.isEnabled = false
        nicNameField.isPossible = nil
        nicNameField.addRightCancelButton()
    }
    
    func popViewController() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(with error: String, title: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let title = title {
                self?.showAlert(title: title, message: error)
            } else {
                self?.showAlert(title: Text.error.rawValue, message: error)
            }
        }
    }
}

extension NickNameChangebleViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        nicNameField.rightButtonHidden = false
        editNickNameButton.isEnabled = false
        nicNameField.isPossible = nil
        
        if let text = textField.text,
           text == "" {
            nicNameField.rightButtonHidden = true
        }
        
        if let count = textField.text?.count {
            changebleNickNameCount(count)
        }
        
        let currentText = textField.text ?? ""
        
        if currentText.count > 8 {
            textField.text = limitText(currentText)
            textField.activeHshakeEffect()
            return
        }
        
        presenter.insertUserNickName(currentText)
        
        checkNicknameDuplicationAfterDelay()
    }
    
    private func changebleNickNameCount(_ count: Int) {
        self.subInfo2.text = "(\(count)/8)"
    }
    
    private func limitText(_ text: String) -> String {
        let startIndex = text.startIndex
        let endIndex = text.index(startIndex, offsetBy: 8 - 1)
        
        let fixedText = String(text[startIndex...endIndex])
                
        return fixedText
    }

    private func checkNicknameDuplicationAfterDelay() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(checkDuplication),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc private func checkDuplication() {
        presenter.checkDuplication()
    }
    
    @objc private func editNicknameButtonTapped() {
        presenter.updateMyNickname()
    }
}

extension NickNameChangebleViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if touch.view is UITextField {
            return false
        }
        
        view.endEditing(true)
        return true
    }
}
