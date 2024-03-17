//
//  MyPageViewPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/28.
//

import UIKit

import KeychainSwift

enum LoginRedirectReason {
    case logout
    case withdrawal
}

protocol MyPageViewProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
//    func updateMyData(_ myDataModel: MyDataModel)
    func pushLoginViewController(with: LoginRedirectReason)
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
    
//    private func loadMyData() {
//        let myNickName = MyData.my.nickname
//        let myStar = String(BookmarkFacadeManager().loadAllData().count)
//        
//        AVIROAPIManager().loadMyContributedCount(with: MyData.my.id) { [weak self] result in
//            switch result {
//            case .success(let success):
//                if success.statusCode == 200 {
//                    if let myPlace = success.data?.placeCount,
//                       let myReview = success.data?.commentCount {
//                        
//                        let myPlaceString = String(myPlace)
//                        let myReviewString = String(myReview)
//                        
//                        self?.myDataModel = MyDataModel(
//                            id: myNickName,
//                            place: myPlaceString,
//                            review: myReviewString,
//                            star: myStar
//                        )
//                    }
//                } else {
//                    self?.viewController?.showErrorAlert(with: "서버 에러", title: nil)
//                }
//            case .failure(let error):
//                if let error = error.errorDescription {
//                    self?.viewController?.showErrorAlert(with: error, title: nil)
//                }
//            }
//        }
//    }
    
    func whenAfterLogout() {
        bookmarkManager.deleteAllData()
        markerManager.deleteAllMarker()
        
        MyData.my.whenLogout()
        UserCoordinate.shared.isFirstLoadLocation = false
        
        self.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
        
        viewController?.pushLoginViewController(with: .logout)
    }
    
    func whenAfterWithdrawal() {
        guard let refreshToken = keychain.get(KeychainKey.appleRefreshToken.rawValue) else { return }
        
        viewController?.switchIsLoading(with: true)

        let model = AVIROAutoLoginWhenAppleUserDTO(refreshToken: refreshToken)
                        
        AVIROAPI.manager.revokeAppleUser(with: model) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    self?.bookmarkManager.deleteAllData()
                    
                    MyData.my.whenLogout()
                    UserCoordinate.shared.isFirstLoadLocation = false
                    self?.keychain.delete(KeychainKey.appleRefreshToken.rawValue)
                    self?.amplitude.withdrawal()
                    
                    DispatchQueue.main.async {
                        self?.markerManager.deleteAllMarker()
                        
                        self?.viewController?.pushLoginViewController(with: .withdrawal)
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
