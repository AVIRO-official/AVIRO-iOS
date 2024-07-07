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
    
    init() {
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else {
            self.clientID = ""
            return
        }
        
        self.clientID = dictionary["Google_Client_ID"] as? String
    }
}

extension GoogleAuthRepository: SocialLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        
    }
    
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        guard let clientID = self.clientID else { return }
        guard let viewController = UIApplication.getMostTopViewController() else { return }
        
        let singinConfig = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] userInfo, error in
            print("userInfo: ", userInfo)
            print("accessToken: ", userInfo?.user.accessToken)
            print("idToken: ", userInfo?.user.idToken)
            print("userID: ", userInfo?.user.userID)
        }
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
