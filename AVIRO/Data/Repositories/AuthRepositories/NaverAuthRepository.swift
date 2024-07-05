//
//  NaverAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

import NaverThirdPartyLogin

final class NaverAuthRepository {
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    init() { 
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else { return }
        
        let consumerKey = (dictionary["Naver_Client_ID"] as? String)!
        let consumerSecret = (dictionary["Naver_Client_Secret"] as? String)!
        
        // 네이버 앱에서 인증
//        instance?.isNaverAppOauthEnable = true
        
        // 사파리에서 인증
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone()
        
        instance?.serviceUrlScheme = "com.aviro.ios"
        instance?.consumerKey = consumerKey
        instance?.consumerSecret = consumerSecret
        instance?.appName = "어비로"
    }
}

extension NaverAuthRepository: NaverAuthRepositoryInterface {
    func loadNaverApp() {
        instance?.requestThirdPartyLogin()
    }
    
    func login(completion: @escaping (Result<String, Error>) -> Void) {

    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func autoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
