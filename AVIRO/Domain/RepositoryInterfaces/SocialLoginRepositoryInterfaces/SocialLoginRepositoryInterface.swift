//
//  SocialLoginRepositoryInterface.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol AppleLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromAppleGoogle) -> Void,
        errorCompletion: @escaping (String) -> Void
    )
    func logout(completion: @escaping (Result<String, Error>) -> Void)
}

protocol GoogleLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromAppleGoogle) -> Void,
        errorCompletion: @escaping (String) -> Void
    )
    func logout(completion: @escaping (Result<String, Error>) -> Void)
}

protocol KakaoLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromKakaoNaver) -> Void,
        errorCompletion: @escaping (String) -> Void
    )
    func logout(completion: @escaping (Result<String, Error>) -> Void)
}

protocol NaverLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromKakaoNaver) -> Void,
        errorCompletion: @escaping (String) -> Void
    )
    func logout(completion: @escaping (Result<String, Error>) -> Void)
}
