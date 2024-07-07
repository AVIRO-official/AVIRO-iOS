//
//  GoogleAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

final class GoogleAuthRepository {
    init() { }
}

extension GoogleAuthRepository: SocialLoginRepositoryInterface {
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func autoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
