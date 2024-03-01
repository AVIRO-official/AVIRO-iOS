//
//  NickNameChangeblePresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/08.
//

import Foundation

protocol NickNameChangebleProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    func setupGesture()
    func changeSubInfo(subInfo: String, isVaild: Bool)
    func initSubInfo()
    func popViewController()
    func showErrorAlert(with error: String, title: String?)
}

final class NickNameChangeblePresenter {
    weak var viewController: NickNameChangebleProtocol?
    
    private var initNickName = MyData.my.nickname
    var userNickname: String?
    
    init(viewController: NickNameChangebleProtocol) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
        viewController?.setupGesture()
    }
    
    func insertUserNickName(_ userNickName: String) {
        self.userNickname = userNickName
    }
    
    func checkDuplication() {
        guard let userNickname = userNickname else { return }
        
        let nickname = AVIRONicknameIsDuplicatedCheckDTO(nickname: userNickname)
        
        if userNickname != initNickName {
            AVIROAPI.manager.checkNickname(with: nickname) { [weak self] result in
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        guard let nicknameIsDuplicatedCheck = model.data else { return }
                        
                        self?.viewController?.changeSubInfo(
                            subInfo: nicknameIsDuplicatedCheck.message,
                            isVaild: nicknameIsDuplicatedCheck.isValid
                        )
                    } else {
                        guard let message = model.message else { return }
                        
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                case .failure(let error):
                    if let error = error.errorDescription {
                        self?.viewController?.showErrorAlert(with: error, title: nil)
                    }
                }
            }
        } else {
            self.viewController?.initSubInfo()
        }
    }
    
    func updateMyNickname() {
        guard let userNickname = userNickname else { return }
        
        let model = AVIRONicknameChagneableDTO(
            userId: MyData.my.id,
            nickname: userNickname
        )
        
        AVIROAPI.manager.editNickname(with: model) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    MyData.my.nickname = userNickname
                    self?.viewController?.popViewController()
                } else {
                    if let message = success.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
}
