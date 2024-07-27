//
//  AppDelegate.swift
//  VeganRestaurant
//
//  Created by 전성훈 on 2023/05/19.
//

import UIKit
// import AuthenticationServices

import NMapsMap
import AmplitudeSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var amplitude: Amplitude?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.setNaverMapAPI()
        self.setAmplitude()
        
        self.registerRepository()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func setNaverMapAPI() {
        guard let keyUrl = Bundle.main.url(
            forResource: "API",
            withExtension: "plist"
        ),
              let dictionary = NSDictionary(
                contentsOf: keyUrl
              ) as? [String: Any] else { return }
                
        let key = (dictionary["NMFAuthManager_Authorization_Key"] as? String)!
        
        NMFAuthManager.shared().clientId = key
    }
    
    private func setAmplitude() {
        guard let keyUrl = Bundle.main.url(
            forResource: "API",
            withExtension: "plist"
        ),
              let dictionary = NSDictionary(
                contentsOf: keyUrl
              ) as? [String: Any] else { return }
        
        let key = (dictionary["Amplitude_Key"] as? String)!
        
        amplitude = Amplitude(configuration: Configuration(apiKey: key))
     }
    
    private func registerRepository() {
        // 수정 필요
//        
//        let host = AVIROConfiguration.host
//        let apiKey = AVIROConfiguration.apikey
//        
//        let headers = [
//            "Content-Type": "application/json",
//            "X-API-KEY": "\(AVIROConfiguration.apikey)"
//        ]
//        
//        let config = APIDataNetworkConfig(baseURL: <#T##URL#>)
//        let apiDataNetwork = NetworkService(config: <#T##any NetworkConfigurable#>)
        
        DIContainer.shared.register(
            AppleAuthRepository.self,
            dependency: AppleAuthRepository()
        )
        
        DIContainer.shared.register(
            GoogleAuthRepository.self,
            dependency: GoogleAuthRepository()
        )
        
        DIContainer.shared.register(
            KakaoAuthRepository.self,
            dependency: KakaoAuthRepository()
        )
        
        DIContainer.shared.register(
            NaverAuthRepository.self,
            dependency: NaverAuthRepository()
        )
    }
}
