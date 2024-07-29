//
//  Singin.swift
//  AVIRO
//
//  Created by 전성훈 on 7/21/24.
//

import Foundation

struct SignInInfo {
    var refreshToken: String?
    var accessToken: String?
    var userID: String?
    var userName: String?
    var userEmail: String?
    var nickname: String?
    var birthday: Int?
    var gender: String?
    var marketAgree: Bool?
    var loginType: LoginType?
}
