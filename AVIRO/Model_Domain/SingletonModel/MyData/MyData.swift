//
//  UserSingleton.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/22.
//

import Foundation

protocol MyDataProtocol {
    func createUser(
        userId: String,
        userName: String,
        userEmail: String,
        userNickname: String,
        marketingAgree: Int
    )
    func whenLogin(
        userId: String,
        userName: String,
        userEmail: String,
        userNickname: String,
        marketingAgree: Int
    )
    func whenLogout()
    func whenWithdrawal()
}

final class MyData: MyDataProtocol {
    static let my = MyData()
    
    private let amplitude: AmplitudeProtocol
    
    var id = ""
    var name = ""
    var email = ""
    var nickname = ""
    var marketingAgree = 0
    
    private init(
        userId: String = "",
        userName: String = "",
        userEmail: String = "",
        userNickName: String = "",
        marketingAgree: Int = 0,
        amplitude: AmplitudeProtocol = AmplitudeUtility.shared
    ) {
        self.id = userId
        self.name = userName
        self.email = userEmail
        self.nickname = userNickName
        self.marketingAgree = marketingAgree
        self.amplitude = amplitude
    }
    
    func createUser(
        userId: String,
        userName: String,
        userEmail: String,
        userNickname: String,
        marketingAgree: Int
    ) {
        self.id = userId
        self.name = userName
        self.email = userEmail
        self.nickname = userNickname
        self.marketingAgree = marketingAgree
        
        amplitude.signUpComplete()
    }
    
    func whenLogin(
        userId: String,
        userName: String,
        userEmail: String,
        userNickname: String,
        marketingAgree: Int
    ) {
        self.id = userId
        self.name = userName
        self.email = userEmail
        self.nickname = userNickname
        self.marketingAgree = marketingAgree
        
        amplitude.loginComplete()
    }
    
    func whenLogout() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.nickname = ""
        self.marketingAgree = 0
        
        amplitude.logoutComplete()
    }
    
    func whenWithdrawal() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.nickname = ""
        self.marketingAgree = 0
        
        amplitude.withdrawalComplete()
    }
}
