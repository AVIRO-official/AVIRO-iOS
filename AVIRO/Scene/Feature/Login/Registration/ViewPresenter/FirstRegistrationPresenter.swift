//
//  RegistrationPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/07.
//

import UIKit

protocol FirstRegistrationProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    func setupGesture()
    
    func changeSubInfo(subInfo: String, isVaild: Bool)
    
    func pushSecondRegistrationView(_ signupModel: AVIROAppleUserSignUpDTO)
    
    func showErrorAlert(with error: String, title: String?)
}

final class FirstRegistrationPresenter {
    weak var viewController: FirstRegistrationProtocol?
    
    var appleSignUpModel: AVIROAppleUserSignUpDTO?
    
    var userNickname: String? {
        didSet {
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(
                timeInterval: 0.2,
                target: self,
                selector: #selector(checkDuplication),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    private var timer: Timer?
        
    init(viewController: FirstRegistrationProtocol,
         appleUserSignUpModel: AVIROAppleUserSignUpDTO? = nil
    ) {
        self.viewController = viewController
        self.appleSignUpModel = appleUserSignUpModel
    }

    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
        viewController?.setupGesture()
    }

    func insertUserNickName(_ userName: String) {
        userNickname = userName
    }
    
    func nicNameCount() -> Int {
        userNickname?.count ?? 0
    }
    
    @objc private func checkDuplication() {

        guard let userNickname = userNickname else { return }
        
        let nickname = AVIRONicknameIsDuplicatedCheckDTO(nickname: userNickname)
        
        AVIROAPI.manager.checkNickname(with: nickname) { [weak self] result in
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    guard let nicknameIsDuplicatedCheck = model.data else { return }
                    
                    self?.viewController?.changeSubInfo(
                        subInfo: nicknameIsDuplicatedCheck.message,
                        isVaild: nicknameIsDuplicatedCheck.isValid
                    )
                } else {
                    guard let message = model.message else { return }
                    
                    self?.viewController?.showErrorAlert(with: message, title: nil)
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
    
    func pushUserInfo() {
        guard var appleSignUpModel = appleSignUpModel else { return }
        
        appleSignUpModel.nickname = userNickname
        
        viewController?.pushSecondRegistrationView(appleSignUpModel)
    }
}
