//
//  LoginViewPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/14.
//

import UIKit

import KeychainSwift

protocol LoginViewProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    
    func switchIsLoading(with loading: Bool)
    
    func pushTabBar()
    func pushRegistrationView(usecase: SocialLoginUseCaseInterface)
    
    func afterLogoutAndMakeToastButton()
    func afterWithdrawalUserShowAlert()
    func showErrorAlert(with error: String, title: String?)
}

final class LoginViewPresenter: NSObject {
    weak var viewController: LoginViewProtocol?
    
    private let keychain = KeychainSwift()
    
    var whenAfterLogout = false
    var whenAfterWithdrawal = false
    
    private let socialLoginUseCase: SocialLoginUseCaseInterface!
    private let amplitude: AmplitudeProtocol
    
    init(
        socialLoginUseCase: SocialLoginUseCaseInterface,
        viewController: LoginViewProtocol,
        amplitude: AmplitudeProtocol
    ) {
        self.socialLoginUseCase = socialLoginUseCase
        self.amplitude = amplitude
        
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
    }
    
    func viewWillAppear() {
        viewController?.switchIsLoading(with: false)
        
        if whenAfterWithdrawal {
            viewController?.afterWithdrawalUserShowAlert()
            whenAfterWithdrawal.toggle()
        }
        
        if whenAfterLogout {
            viewController?.afterLogoutAndMakeToastButton()
            whenAfterLogout.toggle()
        }
    }
    
    func checkMember(type: LoginType) {
        socialLoginUseCase.checkMember(
            type: type,
            requestLogin: {
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.switchIsLoading(with: true)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isMember):
                        self?.amplitude.signUpClick(with: type)
                        self?.viewController?.switchIsLoading(with: false)
                        if isMember {
                            self?.viewController?.pushTabBar()
                        } else {
                            let usecase = self?.socialLoginUseCase
                            self?.viewController?.pushRegistrationView(usecase: usecase!)
                        }
                        
                    case .failure(let error):
                        self?.viewController?.switchIsLoading(with: false)
                        self?.viewController?.showErrorAlert(with: error.localizedDescription, title: nil)
                    }
                }
            }
        )
    }
}
