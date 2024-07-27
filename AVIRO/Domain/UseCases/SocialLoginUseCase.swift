//
//  SocialLoginUseCase.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

import KeychainSwift

protocol SocialLoginUseCaseInterface: AnyObject {
    func checkMember(
        type: LoginType,
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void)
    func logout(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
    func signIn(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
    func withdrawal(
        type: LoginType,
        completion: @escaping (Result<String, Error>) -> Void)
    func firstUpdateSignInInfo(nickname: String)
    func secondUpdateSignInInfo(gender: String, birth: Int)
    func thridUpdateSignInInfo(marketingAgree: Bool)
    func loadSignInInfo() -> SignInInfo
}

final class SocialLoginUseCase {
    private var signinInfo: SignInInfo = SignInInfo()
    
    private let keychain = KeychainSwift()
    
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
                        UserDefaults.standard.set(
                            "apple",
                            forKey: UDKey.loginType.rawValue
                        )
                        self?.keychain.set(
                            result.userData.refreshToken,
                            forKey: KeychainKey.refreshToken.rawValue
                        )
                        completion(.success(true))

                    } else {
                        self?.setupUserDataFromApple(result)
                        self?.signinInfo.loginType = .apple
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
                        UserDefaults.standard.set(
                            "google",
                            forKey: UDKey.loginType.rawValue
                        )
                        self?.keychain.set(
                            result.userData.userId ?? "" ,
                            forKey: KeychainKey.userID.rawValue
                        )
                        completion(.success(true))

                    } else {
                        self?.setupUserDataFromOthers(result)
                        self?.signinInfo.loginType = .google

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
                    if result.isMember {
                        UserDefaults.standard.set(
                            "kakao",
                            forKey: UDKey.loginType.rawValue
                        )
                        self?.keychain.set(
                            result.userData.userId ?? "",
                            forKey: KeychainKey.userID.rawValue
                        )
                        completion(.success(true))
                    } else {
                        self?.setupUserDataFromOthers(result)
                        self?.signinInfo.loginType = .kakao

                        completion(.success(false))
                    }
                },
                errorCompletion: { result in
                    let error = CommonError.temp(result)
                    completion(.failure(error))
                }
            )
        case .naver:
            naverLoginRepository.login(
                requestLogin: requestLogin,
                loginCompletion: { [weak self] result in
                    if result.isMember {
                        UserDefaults.standard.set(
                            "naver",
                            forKey: UDKey.loginType.rawValue
                        )
                        self?.keychain.set(
                            result.userData.userId ?? "" ,
                            forKey: KeychainKey.userID.rawValue
                        )
                        
                        completion(.success(true))
                    } else {
                        self?.setupUserDataFromOthers(result)
                        self?.signinInfo.loginType = .naver

                        completion(.success(false))
                    }
                },
                errorCompletion: { result in
                    let error = CommonError.temp(result)
                    completion(.failure(error))
                }
            )
        }
    }
    
    private func setupUserDataFromApple(_ userInfo: SignInFromApple) {
        signinInfo.refreshToken = userInfo.userData.refreshToken
        signinInfo.accessToken = userInfo.userData.accessToken
        signinInfo.userID = userInfo.userData.userId
        signinInfo.userName = userInfo.userData.userName
        signinInfo.userEmail = userInfo.userData.userEmail
    }
    
    private func setupUserDataFromOthers(_ userInfo: SignInFromKakaoNaver) {
        signinInfo.refreshToken = ""
        signinInfo.accessToken = ""
        signinInfo.userID = userInfo.userData.userId
        signinInfo.userName = ""
        signinInfo.userEmail = ""
    }
    
    func signIn(
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
    
    func firstUpdateSignInInfo(nickname: String) {
        signinInfo.nickname = nickname
    }
    
    func secondUpdateSignInInfo(gender: String, birth: Int) {
        signinInfo.gender = gender
        signinInfo.birthday = birth
    }
    
    func thridUpdateSignInInfo(marketingAgree: Bool) {
        signinInfo.marketAgree = marketingAgree
    }
    
    func loadSignInInfo() -> SignInInfo {
        return signinInfo
    }
}
