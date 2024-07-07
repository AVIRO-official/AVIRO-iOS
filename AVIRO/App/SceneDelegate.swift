//
//  SceneDelegate.swift
//  VeganRestaurant
//
//  Created by 전성훈 on 2023/05/19.
//

import UIKit

import NaverThirdPartyLogin
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        self.window = window
        
        self.window?.rootViewController = LaunchScreenViewController()
        self.window?.makeKeyAndVisible()
        
        if let vc = self.window?.rootViewController as? LaunchScreenViewController {
            vc.afterLaunchScreenEnd = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AppController.shared.show(in: window)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url
        
        // Naver
        if url.scheme == "com.aviro.ios" {
            NaverThirdPartyLoginConnection
                .getSharedInstance()
                .receiveAccessToken(url)
            
            return
        }
        
        // Kakao
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
            
            return
        }
    }
}
