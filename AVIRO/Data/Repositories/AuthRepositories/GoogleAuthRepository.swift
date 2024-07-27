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
    
    private var loginCompletion: ((SignInFromKakaoNaver) -> Void)?
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
        loginCompletion: @escaping (SignInFromKakaoNaver) -> Void,
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
        ) { [weak self] signInResult, error in
            if let error = error {
                self?.errorCompletion?(error.localizedDescription)
                return
            }
            
            guard let user = signInResult,
                let userID = user.user.userID
            else {
                self?.errorCompletion?("구글 사용자 정보를 가져올 수 없습니다.")
                return
            }
            
            let checkMemberDTO = AVIROKakaoUserCheckMemberDTO(userId: userID)
            
            AVIROAPI.manager.checkKakaoUserWhenLogin(with: checkMemberDTO) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    if success.statusCode == 200 || success.statusCode == 400 {
                        let userData = SignInUserDataFromKakaoNaver(userId: userID)
                        var isMember: Bool
                        var nickname = ""
                        var marketingAgree = 0
                        
                        if let data = success.data {
                            isMember = true
                            nickname = data.nickname
                            marketingAgree = data.marketingAgree
                        } else {
                            isMember = false
                        }
                        
                        let model = SignInFromKakaoNaver(
                            isMember: isMember,
                            userData: userData,
                            nickname: nickname,
                            marketingAgree: marketingAgree
                        )
                        
                        self.loginCompletion?(model)
                        
                        return
                    } else {
                        guard let message = success.message else {
                            self.errorCompletion?("서버와 응답이 되지 않습니다.")
                            return
                        }
                        
                        self.errorCompletion?(message)
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
