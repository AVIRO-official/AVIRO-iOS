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
    init() {
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else { return }
        
        let appkey = (dictionary["Kakao_Native_Key"] as? String)!
        
        KakaoSDK.initSDK(appKey: appkey)
    }
}

extension KakaoAuthRepository: KakaoLoginRepositoryInterface {
    func login(requestLogin: () -> Void, loginCompletion: @escaping (SignInFromKakaoNaver) -> Void, errorCompletion: @escaping (String) -> Void) {
        
    }
    
    func login(
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        
    }
    
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                if let error = error {
                    print(error)
                } else {
                    print("token: \(token)")
                    
                    self?.getInfo()
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    private func getInfo() {
        UserApi.shared.me { user, error in
            if let error = error { print(error) }
            let id = user?.id
            print(id)
        }
    }
}
