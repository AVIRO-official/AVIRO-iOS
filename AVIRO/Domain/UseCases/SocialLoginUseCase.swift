//
//  SocialLoginUseCase.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginUseCaseInterface: AnyObject {
    func checkMember(
        type: LoginType,
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void)
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
    func singin(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
    func withdrawal(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
}

final class SocialLoginUseCase {
    private let appleLoginRepository: AppleLoginRepositoryInterface
    private let googleLoginRepository: GoogleLoginRepositoryInterface
    private let kakaoLoginRepository: KakaoLoginRepositoryInterface
    private let naverLoginRepository: NaverLoginRepositoryInterface
    
    init(
        appleLoginRepository: AppleLoginRepositoryInterface,
        googleLoginRepository: GoogleLoginRepositoryInterface,
        kakaoLoginRepository: KakaoLoginRepositoryInterface,
        naverLoginRepository: NaverLoginRepositoryInterface
    ) {
        self.appleLoginRepository = appleLoginRepository
        self.googleLoginRepository = googleLoginRepository
        self.kakaoLoginRepository = kakaoLoginRepository
        self.naverLoginRepository = naverLoginRepository
    }
}

// TODO: String -> Error 번경 후 공통 Error 처리 로직 설계 필요
extension SocialLoginUseCase: SocialLoginUseCaseInterface {
    func checkMember(
        type: LoginType,
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        switch type {
        case .apple:
            appleLoginRepository.login(
                requestLogin: requestLogin,
                loginCompletion: { [weak self] result in
                    if result.isMember {
                        completion(.success(true))
                    } else {
                        self?.setupUserData()
                        completion(.success(false))
                    }
                }, errorCompletion: { result in
                    let error = CommonError.temp(result)
                    completion(.failure(error))
                }
            )
        case .google:
            googleLoginRepository.login(
                requestLogin: requestLogin,
                loginCompletion: { [weak self] result in
                    if result.isMember {
                        completion(.success(true))
                    } else {
                        self?.setupUserData()
                        completion(.success(false))
                    }
                },
                errorCompletion: { result in
                    let error = CommonError.temp(result)
                    completion(.failure(error))
                }
            )
        case .kakao:
            kakaoLoginRepository.login(
                requestLogin: requestLogin,
                loginCompletion: { [weak self] result in
                },
                errorCompletion: { result in
                }
            )
        case .naver:
            naverLoginRepository.login(
                requestLogin: requestLogin,
                loginCompletion: { [weak self] result in
                },
                errorCompletion: { result in
                }
            )
        }
    }
    
    private func setupUserData() {
        
    }
    
    func singin(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
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
