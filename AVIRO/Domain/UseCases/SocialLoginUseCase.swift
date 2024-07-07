//
//  SocialLoginUseCase.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginUseCaseInterface: AnyObject {
    func login(
        type: LoginType,
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    )
    func withdrawal(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    )
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
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        switch type {
        case .apple:
            appleLoginRepository.login(requestLogin: requestLogin) { result in
                
            }
        case .google:
            break
        case .kakao:
            break
        case .naver:
            break
        }
    }
    
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
    }
    
    func withdrawal(
        type: LoginType, 
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
    }
}
