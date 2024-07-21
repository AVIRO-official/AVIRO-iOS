//
//  SignInFromAppleGoogle.swift
//  AVIRO
//
//  Created by 전성훈 on 7/21/24.
//

import Foundation

struct SignInFromAppleGoogle {
    let isMember: Bool
    let userData: SignInUserDataFromAppleGoogle
}

struct SignInUserDataFromAppleGoogle {
    let refreshToken: String
    let accessToken: String
    let userId: String?
    let userName: String?
    let userEmail: String?
}
