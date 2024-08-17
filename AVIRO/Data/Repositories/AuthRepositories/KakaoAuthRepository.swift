//
//  KakaoAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

final class KakaoAuthRepository {
    private var loginCompletion: ((SignInFromKakaoNaver) -> Void)?
    private var errorCompletion: ((String) -> Void)?
        
    init() {
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else { return }
        
        let appkey = (dictionary["Kakao_Native_Key"] as? String)!
        
        KakaoSDK.initSDK(appKey: appkey)
    }
}

extension KakaoAuthRepository: KakaoLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromKakaoNaver) -> Void,
        errorCompletion: @escaping (String) -> Void
    ) {
        requestLogin()
        
        self.loginCompletion = loginCompletion
        self.errorCompletion = errorCompletion
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] _, error in
                if let error = error {
                    self?.errorCompletion?(error.localizedDescription)
                    return
                } else {
                    self?.getInfo()
                }
            }
        }
    }

    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
                return
            } else {
                print("logout() success.")
            }
        }
    }
    
    private func getInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                self.errorCompletion?("카카오 로그인을 사용할 수 없습니다.")
                return
            }
            
            guard let id = user?.id else {
                self.errorCompletion?("카카오 사용자 인증 정보를 가져올 수 없습니다.")
                return
            }
            
            let stringID = String(id)
    
            let checkMemberDTO = AVIROKakaoUserCheckMemberDTO(userId: stringID)
            
            AVIROAPI.manager.checkKakaoUserWhenLogin(with: checkMemberDTO) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    if success.statusCode == 200 || success.statusCode == 400 {
                        let userData = SignInUserDataFromKakaoNaver(userId: stringID)
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
}
