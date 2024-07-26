//
//  ThridRegistrationPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/13.
//

import UIKit

import KeychainSwift

protocol ThridRegistrationProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    func pushFinalRegistrationView()
    func showErrorAlert(with error: String, title: String?)
}

final class ThridRegistrationPresenter {
    enum Term: String {
           case aviroUsage = "어비로 이용 약관 동의 (필수)"
           case personalInfo = "개인정보 수집 및 이용 동의 (필수)"
           case locationService = "위치기반 서비스 이용약관 동의 (필수)"
    }

    weak var viewController: ThridRegistrationProtocol?

    private let keyChain = KeychainSwift()
    private let amplitude: AmplitudeProtocol
    private let socialLoginUseCase: SocialLoginUseCaseInterface!

    private var userInfoModel: AVIROAppleUserSignUpDTO?
        
    var terms: [(Term, Bool)] = [
        (.aviroUsage, false),
        (.personalInfo, false),
        (.locationService, false)
    ]
    
    init(
        socialLoginUseCase: SocialLoginUseCaseInterface,
        viewController: ThridRegistrationProtocol,
         userInfo: AVIROAppleUserSignUpDTO? = nil,
         amplitude: AmplitudeProtocol = AmplitudeUtility()
    ) {
        self.socialLoginUseCase = socialLoginUseCase
        self.viewController = viewController
        self.userInfoModel = userInfo
        self.amplitude = amplitude
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
    }
    
    func clickedTerm(at index: Int) {
        terms[index].1.toggle()
    }
    
    func allAcceptButtonTapped(_ isSelcted: Bool) {
        for index in terms.indices {
            terms[index].1 = isSelcted
        }
    }
    
    func checkAllRequiredTerms() -> Bool {
        return !terms.contains(where: { $0.1 == false })
    }
    
    func pushUserInfo() {
        let userInfo = socialLoginUseCase.loadSignInInfo()
        
        let userSignUpDTO = AVIROAppleUserSignUpDTO.makeUserSignUpDTO(signInInfo: userInfo)
        
        AVIROAPI.manager.createAppleUser(with: userSignUpDTO) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    if let data = success.data {
                        switch userInfo.loginType {
                        case .apple:
                            self?.keyChain.set(
                                userInfo.refreshToken ?? "",
                                forKey: KeychainKey.refreshToken.rawValue
                            )
                            self?.keyChain.delete(
                                KeychainKey.userID.rawValue
                            )
                        default:
                            self?.keyChain.set(
                                userInfo.userID ?? "",
                                forKey: KeychainKey.userID.rawValue
                            )
                            self?.keyChain.delete(
                                KeychainKey.refreshToken.rawValue
                            )
                        }
                        self?.amplitude.signUp(with: data.userId)
                        
                        MyData.my.whenLogin(
                            userId: data.userId,
                            userName: data.userName,
                            userEmail: data.userEmail,
                            userNickname: data.nickname,
                            marketingAgree: data.marketingAgree
                        )
                        self?.viewController?.pushFinalRegistrationView()
                    }
                } else {
                    if let message = success.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
}
