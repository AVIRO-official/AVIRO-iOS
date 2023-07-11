//
//  RegistrationPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/07.
//

import UIKit

protocol FirstRegistrationProtocol: NSObject {
    func makeLayout()
    func makeAttribute()
    func changeSubInfo(subInfo: String, isVaild: Bool)
}

final class FirstRegistrationPresenter {
    weak var viewController: FirstRegistrationProtocol?
    
    var userInfoModel: UserInfoModel?
    
    var userNicname: String?
    
    private let aviroManager = AVIROAPIManager()
    
    init(viewController: FirstRegistrationProtocol, userInfoModel: UserInfoModel? = nil) {
        self.viewController = viewController
        self.userInfoModel = userInfoModel
    }
    
    func viewDidLoad() {
        viewController?.makeLayout()
        viewController?.makeAttribute()
    }
    
    func insertUserNicName(_ userName: String) {
        userNicname = userName
    }
    
    func nicNameCount() -> Int {
        userNicname?.count ?? 0
    }
    
    func checkDuplication() {
        let nicname = NicnameCheckInput(nickname: userNicname)
        aviroManager.postCheckNicname(nicname) { result in
            let result = NicnameCheck(statusCode: result.statusCode, isValid: result.isValid, message: result.message)
            
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.changeSubInfo(subInfo: result.message, isVaild: result.isValid)
            }
        }
    }
}
