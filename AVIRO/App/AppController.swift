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
    
    private var window: UIWindow!
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    
    private init() { }
    
    // MARK: 외부랑 소통할 메서드
    func show(in window: UIWindow) {
        self.window = window
        window.backgroundColor = .gray7
        
        checkState()
    }
    
    func setupLoginViewAfterLogout(in window: UIWindow, with type: LoginViewToastType) {
        self.window = window
        window.backgroundColor = .gray7
        
        setLoginView(type: type)
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
        window.makeKeyAndVisible()
    }
    
    // MARK: login View
    private func setLoginView(type: LoginViewToastType = .none) {
        let loginVC = LoginViewController()
        let presenter = LoginViewPresenter(viewController: loginVC)
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
        window.makeKeyAndVisible()
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
        
        rootViewController = tabBarVC
        
        tabBarVC.selectedIndex = 0
        
        window.makeKeyAndVisible()
    }
}
