//
//  SocialLoginUseCase.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginUseCaseInterface: AnyObject {
    func loadURL(type: LoginType)
    func login(type: LoginType, completion: @escaping (Result<String, Error>) -> Void)
    func logout(type: LoginType, completion: @escaping (Result<String, Error>) -> Void)
}

final class SocialLoginUseCase {
    private let appleLoginRepository: AppleAuthRepositoryInterface
    private let googleLoginRepository: GoogleAuthRepositoryInterface
    private let kakaoLoginRepository: KakaoAuthRepositoryInterface
    private let naverLoginRepository: NaverAuthRepositoryInterface
    
    init(
        appleLoginRepository: AppleAuthRepositoryInterface,
        googleLoginRepository: GoogleAuthRepositoryInterface,
        kakaoLoginRepository: KakaoAuthRepositoryInterface,
        naverLoginRepository: NaverAuthRepositoryInterface
    ) {
        self.appleLoginRepository = appleLoginRepository
        self.googleLoginRepository = googleLoginRepository
        self.kakaoLoginRepository = kakaoLoginRepository
        self.naverLoginRepository = naverLoginRepository
    }
}

extension SocialLoginUseCase: SocialLoginUseCaseInterface {
    func loadURL(type: LoginType) {
        switch type {
        case .apple:
            break
        case .google:
            break
        case .kakao:
            break
        case .naver:
            naverLoginRepository.loadNaverApp()
        }
    }
    
    func login(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch type {
        case .apple:
            break
        case .google:
            break
        case .kakao:
            break
        case .naver:
            naverLoginRepository.login(completion: { result in
            })
        }
    }
    
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
    }
}
