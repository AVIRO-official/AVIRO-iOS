//
//  MyPageViewPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/28.
//

import UIKit

import KeychainSwift

enum LoginViewToastType {
    case logout
    case withdrawal
    case none
}

protocol MyPageViewProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
//    func updateMyData(_ myDataModel: MyDataModel)
    func pushLoginViewController(type: LoginViewToastType)
    func showErrorAlert(with error: String, title: String?)
    func switchIsLoading(with loading: Bool)
}

final class SettingViewPresenter {
    weak var viewController: MyPageViewProtocol?
    
    private let bookmarkManager: BookmarkFacadeManager
    private let markerManager: MarkerModelManagerProtocol
    private let amplitude: AmplitudeProtocol
    private let keychain = KeychainSwift()
    
//    private var myDataModel: MyDataModel? {
//        didSet {
//            guard let myDataModel = myDataModel else { return }
//            DispatchQueue.main.async {
//                self.viewController?.updateMyData(myDataModel)
//            }
//        }
//    }
    
    init(viewController: MyPageViewProtocol,
         bookmarkManager: BookmarkFacadeManager = BookmarkFacadeManager(),
         markerManager: MarkerModelManagerProtocol = MarkerModelManager(),
         amplitude: AmplitudeProtocol = AmplitudeUtility()
    ) {
        self.viewController = viewController
        self.bookmarkManager = bookmarkManager
        self.markerManager = markerManager
        self.amplitude = amplitude
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
    }
    
    func viewWillAppear() {
//        viewController?.switchIsLoading(with: false)

//        loadMyData()
    }
    
    func whenAfterLogout() {
        bookmarkManager.deleteAllData()
        markerManager.deleteAllMarker()
        
        MyData.my.whenLogout()
        UserCoordinate.shared.isFirstLoadLocation = false
        
        self.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
        self.keychain.delete(KeychainKey.refreshToken.rawValue)
        self.keychain.delete(KeychainKey.userID.rawValue)
        UserDefaults.standard.set(
            "none",
            forKey: UDKey.loginType.rawValue
        )
        
        viewController?.pushLoginViewController(type: .logout)
    }
    
    func whenAfterWithdrawal() {
        guard let type = UserDefaults.standard.string(
            forKey: UDKey.loginType.rawValue
        ) else { return }
        
        var token = ""
        
        if type == "apple" {
            token = keychain.get(
                KeychainKey.refreshToken.rawValue
            ) ?? ""
        } else {
            token = keychain.get(KeychainKey.userID.rawValue) ?? ""
        }
        
        viewController?.switchIsLoading(with: true)
        
        let model = AVIRORevokeUserDTO(
            refreshToken: token,
            type: type
        )
                        
        AVIROAPI.manager.revokeAppleUser(with: model) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    self?.bookmarkManager.deleteAllData()
                    
                    MyData.my.whenLogout()
                    UserCoordinate.shared.isFirstLoadLocation = false
                    self?.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
                    self?.keychain.delete(KeychainKey.refreshToken.rawValue)
                    self?.keychain.delete(KeychainKey.userID.rawValue)
                    UserDefaults.standard.set(
                        "none",
                        forKey: UDKey.loginType.rawValue
                    )
                    
                    self?.amplitude.withdrawal()
                    
                    DispatchQueue.main.async {
                        self?.markerManager.deleteAllMarker()
                        
                        self?.viewController?.pushLoginViewController(type: .withdrawal)
                    }
                } else {
                    self?.viewController?.switchIsLoading(with: false)

                    if let message = success.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                self?.viewController?.switchIsLoading(with: false)

                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
}
