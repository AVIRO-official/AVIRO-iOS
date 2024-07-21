//
//  AppleAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation
import AuthenticationServices

final class AppleAuthRepository: NSObject {
    private let backgroundQueue: DataTransferDispatchQueue
    private var loginCompletion: ((SignInFromAppleGoogle) -> Void)?
    private var errorCompletion: ((String) -> Void)?
    init(
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.backgroundQueue = backgroundQueue
    }
}

extension AppleAuthRepository: AppleLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromAppleGoogle) -> Void,
        errorCompletion: @escaping (String) -> Void
    ) {
        requestLogin()
        
        self.loginCompletion = loginCompletion
        self.errorCompletion = errorCompletion
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}

extension AppleAuthRepository: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let authorizationCode = appleIDCredential.authorizationCode,
                  let identityToken = appleIDCredential.identityToken else { return }
            
            let fullName = appleIDCredential.fullName?.formatted() ?? " "
            let email = appleIDCredential.email ?? " "
            
            let token = String(data: identityToken, encoding: .utf8)!
            let code = String(data: authorizationCode, encoding: .utf8)!
            
            let memberCheckDTO = AVIROAppleUserCheckMemberDTO(
                identityToken: token,
                authorizationCode: code
            )
            
            AVIROAPI.manager.checkAppleUserWhenLogin(
                with: memberCheckDTO
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    if success.statusCode == 200,
                       let data = success.data {
                        let userData = SignInUserDataFromAppleGoogle(
                            refreshToken: data.refreshToken,
                            accessToken: data.accessToken,
                            userId: data.userId,
                            userName: fullName,
                            userEmail: email
                        )
                        
                        let model = SignInFromAppleGoogle(
                            isMember: data.isMember,
                            userData: userData
                        )
                        
                        self.loginCompletion?(model)
                    } else {
                        guard let errorMessage = success.message else { return }
                        self.errorCompletion?(errorMessage)
                    }
                case .failure(let error):
                    if let errorMessage = error.errorDescription {
                        self.errorCompletion?(errorMessage)
                    }
                }
            }
        }
    }
}
