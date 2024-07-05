//
//  SocialLoginRepositoryInterface.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginRepositoryInterface {
    // TODO: Make Result `User` Model
    func login(completion: @escaping (Result<String, Error>) -> Void)
    // TODO: Match the existing output
    func logout(completion: @escaping (Result<String, Error>) -> Void)
    func autoLogin(completion: @escaping (Result<String, Error>) -> Void)
}

protocol AppleAuthRepositoryInterface: SocialLoginRepositoryInterface {
    
}

protocol GoogleAuthRepositoryInterface: SocialLoginRepositoryInterface {
    
}

protocol KakaoAuthRepositoryInterface: SocialLoginRepositoryInterface {
    
}

protocol NaverAuthRepositoryInterface: SocialLoginRepositoryInterface {
    func loadNaverApp()
}
