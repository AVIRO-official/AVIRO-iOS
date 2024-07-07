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
    
    init(
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.backgroundQueue = backgroundQueue
    }
}

extension AppleAuthRepository: SocialLoginRepositoryInterface {
    func login(completion: @escaping (Result<String, Error>) -> Void) {
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
            
            let code = String(data: authorizationCode, encoding: .utf8)!
            let token = String(data: identityToken, encoding: .utf8)!
            
            let fullName = appleIDCredential.fullName?.formatted() ?? ""
            let email = appleIDCredential.email ?? ""
            
            let model = AppleUserLoginModel(
                identityToken: token,
                authorizationCode: code,
                userName: fullName,
                userEmail: email
            )
            
            print(model)
        }
    }
}
