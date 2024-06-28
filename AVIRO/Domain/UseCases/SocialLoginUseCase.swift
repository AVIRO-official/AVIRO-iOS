//
//  SocialLoginUseCase.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginUseCaseInterface: AnyObject {
    func login(type: LoginType, completion: @escaping (Result<String, Error>) -> Void)
    func logout(type: LoginType, completion: @escaping (Result<String, Error>) -> Void)
}

final class SocialLoginUseCase {
    private let appleLoginRepository: SocialLoginRepositoryInterface
    private let googleLoginRepository: SocialLoginRepositoryInterface
    private let kakaoLoginRepository: SocialLoginRepositoryInterface
    private let naverLoginRepository: SocialLoginRepositoryInterface
    
    init(
        appleLoginRepository: SocialLoginRepositoryInterface,
        googleLoginRepository: SocialLoginRepositoryInterface,
        kakaoLoginRepository: SocialLoginRepositoryInterface,
        naverLoginRepository: SocialLoginRepositoryInterface
    ) {
        self.appleLoginRepository = appleLoginRepository
        self.googleLoginRepository = googleLoginRepository
        self.kakaoLoginRepository = kakaoLoginRepository
        self.naverLoginRepository = naverLoginRepository
    }
}

extension SocialLoginUseCase: SocialLoginUseCaseInterface {
    func login(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
    }
    
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
    }
}
