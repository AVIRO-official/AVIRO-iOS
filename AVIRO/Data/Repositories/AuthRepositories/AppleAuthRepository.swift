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
    private var loginCompletion: ((Result<Bool, Error>) -> Void)?
    
    init(
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.backgroundQueue = backgroundQueue
    }
}

extension AppleAuthRepository: SocialLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        requestLogin()
        self.loginCompletion = completion
        
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
            
            let token = String(data: identityToken, encoding: .utf8)!
            let code = String(data: authorizationCode, encoding: .utf8)!

            let memberCheckDTO = AVIROAppleUserCheckMemberDTO(
                identityToken: token,
                authorizationCode: code
            )
            
            AVIROAPI.manager.checkAppleUserWhenLogin(with: memberCheckDTO) { [weak self] result in
                switch result {
                case .success(let success):
                    if success.statusCode == 200 {
                        self?.loginCompletion?(.success(true))
                    } else {
                        self?.loginCompletion?(.success(true))
                    }
                case .failure(let error):
                    if let error = error.errorDescription {
                        self?.loginCompletion?(.success(true))

                    }
                }
            }
        }
    }
}
