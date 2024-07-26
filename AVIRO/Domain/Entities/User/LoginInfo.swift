//
//  LoginInfo.swift
//  AVIRO
//
//  Created by 전성훈 on 6/28/24.
//

import Foundation

enum LoginType: String {
    case apple
    case google
    case kakao
    case naver
}

struct LoginInfo {
    var refreshToken: String?
    var userID: String?
    var type: LoginType
}
