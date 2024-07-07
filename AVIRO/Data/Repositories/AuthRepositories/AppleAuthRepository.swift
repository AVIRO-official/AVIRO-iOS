//
//  AppleAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

final class AppleAuthRepository {
    init() { }
}

extension AppleAuthRepository: SocialLoginRepositoryInterface {
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func autoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
