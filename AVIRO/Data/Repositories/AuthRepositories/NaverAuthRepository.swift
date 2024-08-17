//
//  NaverAuthRepository.swift
//  AVIRO
//
//  Created by 전성훈 on 7/5/24.
//

import Foundation

import NaverThirdPartyLogin

final class NaverAuthRepository: NSObject {
    private let naverDataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    private let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    private var loginCompletion: ((SignInFromKakaoNaver) -> Void)?
    private var errorCompletion: ((String) -> Void)?
    
    init(
        //        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.backgroundQueue = backgroundQueue
        
        let urlStr = "https://openapi.naver.com/"
        let url = URL(string: urlStr)!
        let naverAPIConfig = APIDataNetworkConfig(baseURL: url)
        
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

extension NaverAuthRepository: NaverLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        loginCompletion: @escaping (SignInFromKakaoNaver) -> Void,
        errorCompletion: @escaping (String) -> Void
    ) {
        instance?.delegate = self
        instance?.requestThirdPartyLogin()
        
        self.loginCompletion = loginCompletion
        self.errorCompletion = errorCompletion
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        instance?.requestDeleteToken()
    }
    
    private func getInfo() {
        guard let isValidAccessToken = instance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken { return }
        
        guard let tokenType = instance?.tokenType,
              let accessType = instance?.accessToken
        else { return }
        
        let authorization = "\(tokenType) \(accessType)"
        
        let endpoint = EndPoint<NaverUserInfoResponseDTO>(
            path: "v1/nid/me",
            method: .get,
            headerParameters: ["Authorization": authorization]
        )
        
        _ = naverDataTransferService.request(
            with: endpoint,
            on: backgroundQueue) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let userInfo):
                    let checkMemberDTO = AVIROKakaoUserCheckMemberDTO(userId: userInfo.id)
                    
                    AVIROAPI.manager.checkKakaoUserWhenLogin(
                        with: checkMemberDTO) { result in
                            switch result {
                            case .success(let success):
                                if success.statusCode == 200 || success.statusCode == 400 {
                                    let userData = SignInUserDataFromKakaoNaver(userId: userInfo.id)
                                    var isMember: Bool
                                    var nickname = ""
                                    var marketingAgree = 0
                                    
                                    if let data = success.data {
                                        isMember = true
                                        nickname = data.nickname
                                        marketingAgree = data.marketingAgree
                                    } else {
                                        isMember = false
                                    }
                                    
                                    let model = SignInFromKakaoNaver(
                                        isMember: isMember,
                                        userData: userData,
                                        nickname: nickname,
                                        marketingAgree: marketingAgree
                                    )

                                    self.loginCompletion?(model)

                                    return
                                } else {
                                    guard let message = success.message else {
                                        self.errorCompletion?("서버와 응답이 되지 않습니다.")
                                        return
                                    }
                                    
                                    self.errorCompletion?(message)
                                }
                            case .failure(let error):
                                if let errorMessage = error.errorDescription {
                                    self.errorCompletion?(errorMessage)
                                }
                            }
                        }
                case .failure(let error):
                    self.errorCompletion?(error.localizedDescription)
                    return
                }
            }
    }
}

extension NaverAuthRepository: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        getInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        getInfo()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    
    func oauth20Connection(
        _ oauthConnection: NaverThirdPartyLoginConnection!,
        didFailWithError error: Error) {
            
        }
}

struct NaverUserInfoResponseDTO: Decodable {
    let id: String
    
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

