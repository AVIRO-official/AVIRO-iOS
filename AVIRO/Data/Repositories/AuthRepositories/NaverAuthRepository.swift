//
//  NaverAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

import NaverThirdPartyLogin

final class NaverAuthRepository: NSObject {
//    private let aviroDataTransferService: DataTransferService
    private let naverDataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue

    private let instance = NaverThirdPartyLoginConnection.getSharedInstance()

    init(
//        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.backgroundQueue = backgroundQueue
        
        let urlStr = "https://openapi.naver.com/"
        let url = URL(string: urlStr)!
        let naverAPIConfig = APIDataNetworkConfig(baseURL: url)
        
//        self.aviroDataTransferService = dataTransferService
        self.naverDataTransferService = DataTransferService(
            networkService: NetworkService(config: naverAPIConfig)
        )
        
        guard let keyURL = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: keyURL) as? [String: Any] else { return }
        
        let consumerKey = (dictionary["Naver_Client_ID"] as? String)!
        let consumerSecret = (dictionary["Naver_Client_Secret"] as? String)!
        
        // 네이버 앱에서 인증
//        instance?.isNaverAppOauthEnable = true
        
        // 사파리에서 인증
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone()
        
        instance?.serviceUrlScheme = "com.aviro.ios"
        instance?.consumerKey = consumerKey
        instance?.consumerSecret = consumerSecret
        instance?.appName = "어비로"
    }
}

extension NaverAuthRepository: SocialLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        
    }

    func login(completion: @escaping (Result<String, Error>) -> Void) {
        instance?.delegate = self
        instance?.requestThirdPartyLogin()
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        instance?.requestDeleteToken()
    }
    
    private func getInfo() {
        guard let isValidAccessToken = instance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken { return }
        
        guard let tokenType = instance?.tokenType,
              let accessType = instance?.accessToken,
              let refreshToke = instance?.refreshToken
        else { return }
        
        let authorization = "\(tokenType) \(accessType)"
                
        let endpoint = EndPoint<NaverUserInfoResponseDTO>(
            path: "v1/nid/me",
            method: .get,
            headerParameters: ["Authorization": authorization]
        )
        
        let req = naverDataTransferService.request(
            with: endpoint,
            on: backgroundQueue) { result in
                switch result {
                case .success(let userInfo):
                    let contentText = """
                       userId : \(userInfo.id)
                       """
                    
                    print(contentText)
                case .failure(let error):
                    print("Error \(error)")
                }
            }
                
    }
}

extension NaverAuthRepository: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success Login")
        getInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("TestTest")
        instance?.accessToken
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Log out")
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        print("error")
    }
}

struct NaverUserInfoResponseDTO: Decodable {
    let id: String
//    let name: String
    
    private enum RootKeys: String, CodingKey {
        case response
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let responseContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        
        id = try responseContainer.decode(String.self, forKey: .id)
    }
}

