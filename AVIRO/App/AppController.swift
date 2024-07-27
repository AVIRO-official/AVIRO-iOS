//
//  AppController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/05.
//

import Foundation

import KeychainSwift

// MARK: 처음 켰을 때 자동로그인 확인
final class AppController {
    static let shared = AppController()
    
    private let keychain = KeychainSwift()
    private let amplitude = AmplitudeUtility()
    
    private let socialLoginUsecase: SocialLoginUseCase
    
    private var window: UIWindow!
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }
    
    private init() {
        let container = DIContainer.shared
        
        self.socialLoginUsecase = SocialLoginUseCase(
            appleLoginRepository: container.resolve(AppleAuthRepository.self)!,
            googleLoginRepository: container.resolve(GoogleAuthRepository.self)!,
            kakaoLoginRepository: container.resolve(KakaoAuthRepository.self)!,
            naverLoginRepository: container.resolve(NaverAuthRepository.self)!
        )
    }
    
    // MARK: 외부랑 소통할 메서드
    func show(in window: UIWindow) {
        self.window = window
        window.backgroundColor = .gray7

//        setTabBarView()
        checkLoginType()
    }
    
    private func checkLoginType() {
        // 최초 튜토리얼 화면 안 봤을 때
        guard UserDefaults.standard.bool(forKey: UDKey.tutorial.rawValue) else {
            setTutorialView()
            return
        }
        
        if let loginType = UserDefaults.standard.string(forKey: UDKey.loginType.rawValue) {
            switch loginType {
            case "apple":
                checkMemberFromApple()
            case "google", "kakao", "naver":
                checkMemberFromOthers()
            case "none":
                setLoginView()
            default:
                setLoginView()
            }
        } else {
            // login type 업데이트 전 자동로그인 적용을 위해 사전 작업
            if let userKey = keychain.get(KeychainKey.appleRefreshToken.rawValue) {
                UserDefaults.standard.set(
                    LoginTypeKey.apple.rawValue,
                    forKey: UDKey.loginType.rawValue
                )
                
                keychain.set(
                    userKey,
                    forKey: KeychainKey.refreshToken.rawValue
                )
                
                keychain.delete(KeychainKey.appleRefreshToken.rawValue)
                
                checkMemberFromApple()
            } else {
                UserDefaults.standard.set(
                    LoginTypeKey.none.rawValue,
                    forKey: UDKey.loginType.rawValue
                )
                
                setLoginView()
            }
        }
    }
    
    private func checkMemberFromApple() {
        keychain.delete(KeychainKey.userID.rawValue)
        
        guard let refreshToken = keychain.get(KeychainKey.refreshToken.rawValue) else {
            setLoginView()
            return
        }
        
        let userCheck = AVIROAutoLoginWhenAppleUserDTO(refreshToken: refreshToken)
        
        AVIROAPI.manager.checkAppleUserWhenInitiate(with: userCheck) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        if let data = model.data {
                            MyData.my.whenLogin(
                                userId: data.userId,
                                userName: data.userName,
                                userEmail: data.userEmail,
                                userNickname: data.nickname,
                                marketingAgree: data.marketingAgree
                            )
                            
                            self?.setTabBarView()
                        }
                    } else {
                        self?.keychain.delete(KeychainKey.refreshToken.rawValue)
                        self?.setLoginView()
                    }
                case .failure(_):
                    self?.keychain.delete(KeychainKey.refreshToken.rawValue)
                    self?.setLoginView()
                }
            }
        }
    }
    
    private func checkMemberFromOthers() {
        keychain.delete(KeychainKey.refreshToken.rawValue)
        
        guard let userID = keychain.get(KeychainKey.userID.rawValue) else {
            print("ADAWDAW")
            setLoginView()
            return
        }
        
        let userCheck = AVIROKakaoUserCheckMemberDTO(userId: userID)
        print("TSET")
        AVIROAPI.manager.checkKakaoUserWhenLogin(with: userCheck) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        if let data = model.data {
                            MyData.my.whenLogin(
                                userId: userID,
                                userName: "",
                                userEmail: "",
                                userNickname: data.nickname,
                                marketingAgree: data.marketingAgree
                            )
                            
                            self?.setTabBarView()
                        }
                    } else {
                        self?.keychain.delete(KeychainKey.userID.rawValue)
                        self?.setLoginView()
                    }
                case .failure(_):
                    self?.keychain.delete(KeychainKey.userID.rawValue)
                    self?.setLoginView()
                }
            }
        }
        
    }
    
    // MARK: 불러올 view 확인 메서드
    private func checkState() {
        let userKey = keychain.get(KeychainKey.appleRefreshToken.rawValue)
        
        // 최초 튜토리얼 화면 안 봤을 때
        guard UserDefaults.standard.bool(forKey: UDKey.tutorial.rawValue) else {
            setTutorialView()
            return
        }

        // 자동로그인 토큰 없을 때
        guard let userKey = userKey else {
            setLoginView()
            return
        }

        let userCheck = AVIROAutoLoginWhenAppleUserDTO(refreshToken: userKey)

        // TODO: user 정보 불러오기 수정
        AVIROAPI.manager.checkAppleUserWhenInitiate(with: userCheck) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        if let data = model.data {
                            MyData.my.whenLogin(
                                userId: data.userId,
                                userName: data.userName,
                                userEmail: data.userEmail,
                                userNickname: data.nickname,
                                marketingAgree: data.marketingAgree
                            )
                            self?.setTabBarView()
                        }
                    } else {
                        self?.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
                        self?.setLoginView()
                    }
                case .failure:
                    self?.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
                    self?.setLoginView()
                }
            }
        }
    }
    
    // MARK: tutorial View
    private func setTutorialView() {
        let tutorialVC = TutorialViewController()
        
        rootViewController = UINavigationController(rootViewController: tutorialVC)
    }
    
    // MARK: login View
    private func setLoginView(type: LoginViewToastType = .none) {
        let loginVC = LoginViewController()
        let presenter = LoginViewPresenter(
            socialLoginUseCase: socialLoginUsecase,
            viewController: loginVC
        )
        
        loginVC.presenter = presenter
        
        switch type {
        case .logout:
            presenter.whenAfterLogout = true
        case .withdrawal:
            presenter.whenAfterWithdrawal = true
        case .none:
            break
        }
        
        rootViewController = UINavigationController(rootViewController: loginVC)
    }
    
    // MARK: TabBar View
    private func setTabBarView() {
        let tabBarVC = AVIROTabBarController.create(
            amplitude: self.amplitude,
            type: [
                TabBarType.home,
                TabBarType.plus,
                TabBarType.challenge
            ]
        )
        tabBarVC.selectedIndex = 0

        rootViewController = tabBarVC
    }
    
    func setupLoginViewAfterLogout(
        in window: UIWindow,
        with type: LoginViewToastType
    ) {
        self.window = window
        window.backgroundColor = .gray7
        
        setLoginView(type: type)
    }
}
