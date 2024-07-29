//
//  SignInFromKakaoNaver.swift
//  AVIRO
//
//  Created by 전성훈 on 7/21/24.
//

import Foundation

struct SignInFromKakaoNaver {
    let isMember: Bool
    let userData: SignInUserDataFromKakaoNaver
    
    let nickname: String
    let marketingAgree: Int
}

struct SignInUserDataFromKakaoNaver {
    let userId: String?
}
