//
//  GoogleAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

import GoogleSignIn

final class GoogleAuthRepository {
    private let clientID: String?
    
    private var loginCompletion: ((SignInFromAppleGoogle) -> Void)?
    private var errorCompletion: ((String) -> Void)?
    
    init() {
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else {
            self.clientID = ""
            return
        }
        
        self.clientID = dictionary["Google_Client_ID"] as? String
    }
}

extension GoogleAuthRepository: GoogleLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromAppleGoogle) -> Void,
        errorCompletion: @escaping (String) -> Void
    ) {
        guard let clientID = self.clientID,
              let viewController = UIApplication.getMostTopViewController()
        else {
            errorCompletion("구글 로그인을 사용할 수 없습니다.")
            return
        }
        
        requestLogin()
        
        self.loginCompletion = loginCompletion
        self.errorCompletion = errorCompletion
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController
        ) { [weak self] user, error in
            if let error = error {
                self?.errorCompletion?(error.localizedDescription)
                return
            }
            
            guard let user = user else {
                self?.errorCompletion?("구글 사용자 정보를 가져올 수 없습니다.")
                return
            }
            
            guard let idToken = user.user.idToken?.tokenString,
                  let authorizationCode = user.serverAuthCode else {
                self?.errorCompletion?("구글 사용자 인증 정보를 가져올 수 없습니다.")
                return
            }
            
            
            let memberCheckDTO = AVIROAppleUserCheckMemberDTO(
                identityToken: idToken,
                authorizationCode: authorizationCode
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
                            userId: user.user.userID,
                            userName: user.user.profile?.name,
                            userEmail: user.user.profile?.email
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
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
