//
//  KakaoAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

final class KakaoAuthRepository {
    init() { }
}

extension KakaoAuthRepository: KakaoAuthRepositoryInterface {
    func login(completion: @escaping (Result<String, Error>) -> Void) {
    
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    func autoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
