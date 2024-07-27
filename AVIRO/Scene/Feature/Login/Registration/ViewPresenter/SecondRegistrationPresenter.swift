//
//  SecondRegistrationPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/12.
//

import UIKit

protocol SecondRegistrationProtocol: NSObject {
    func setupLayout()
    func setupGesture()
    func setupAttribute()
    func setupGenderButton()

    func isValidDate(with isValid: Bool)
    
    func pushThridRegistrationView(usecase: SocialLoginUseCaseInterface)
}

final class SecondRegistrationPresenter {
    weak var viewController: SecondRegistrationProtocol?
    
    private let socialLoginUseCase: SocialLoginUseCaseInterface!

    private var userInfoModel: AVIROAppleUserSignUpDTO?
    
    var birth = "" {
        didSet {
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(afterEndTimer),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    var gender: Gender?
    private var isWrongBirth = true
        
    private var timer: Timer?
    
    init(
        socialLoginUseCase: SocialLoginUseCaseInterface,
        viewController: SecondRegistrationProtocol,
         userInfoModel: AVIROAppleUserSignUpDTO? = nil
    ) {
        self.socialLoginUseCase = socialLoginUseCase
        self.viewController = viewController
        self.userInfoModel = userInfoModel
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
        viewController?.setupGesture()
        viewController?.setupGenderButton()
    }
    
    func pushUserInfo() {
        let gender = gender?.rawValue ?? ""
        if isWrongBirth {
            birth = "0"
        }
        
        let birth = Int(birth.components(separatedBy: ".").joined()) ?? 0
            
        socialLoginUseCase.secondUpdateSignInInfo(
            gender: gender,
            birth: birth
        )
        
        viewController?.pushThridRegistrationView(usecase: socialLoginUseCase)
    }
    
    @objc func afterEndTimer() {
        checkInvalidDate()
    }
    
    private func checkInvalidDate() {
        isWrongBirth = !TimeUtility.isValidDate(birth)
        viewController?.isValidDate(with: !isWrongBirth)
    }
}
