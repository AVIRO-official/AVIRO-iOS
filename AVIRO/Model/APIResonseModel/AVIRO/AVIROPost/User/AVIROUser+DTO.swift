//
//  UserInfoModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/29.
//

import Foundation

struct AVIROAutoLoginWhenAppleUserDTO: Encodable {
    let refreshToken: String
}

struct AVIROAutoLoginWhenAppleUserResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROUserDataDTO?
    let message: String?
}

struct AVIROUserDataDTO: Codable {
    let userId: String
    let userName: String
    let userEmail: String
    let nickname: String
    let marketingAgree: Int
}

struct AVIROAppleUserCheckMemberDTO: Encodable {
    let identityToken: String
    let authorizationCode: String
}

struct AVIROAppleUserCheckMemberResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROAppleUserRawData?
    let message: String?
}

struct AVIROAppleUserRawData: Decodable {
    let isMember: Bool
    let refreshToken: String
    let accessToken: String
    let userId: String?
}

struct AVIROKakaoUserCheckMemberDTO: Encodable {
    let userId: String
}

struct AVIROKakaoUserCheckMemberResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROKakaoUserRawData?
    let message: String?
}

struct AVIROKakaoUserRawData: Decodable {
    let nickname: String
    let marketingAgree: Int
}

struct AVIROAppleUserSignUpDTO: Codable {
    let refreshToken: String
    let accessToken: String
    let userId: String
    var userName: String?
    var userEmail: String?
    var nickname: String?
    var birthday: Int?
    var gender: String?
    var marketingAgree: Bool?
    var type: String
    
    static func makeUserSignUpDTO(signInInfo: SignInInfo) -> Self {
        let dto = AVIROAppleUserSignUpDTO(
            refreshToken: signInInfo.refreshToken ?? "",
            accessToken: signInInfo.accessToken ?? "",
            userId: signInInfo.userID ?? "",
            userName: signInInfo.userName,
            userEmail: signInInfo.userEmail,
            birthday: signInInfo.birthday,
            gender: signInInfo.gender,
            marketingAgree: signInInfo.marketAgree,
            type: signInInfo.loginType?.rawValue ?? ""
        )
        
        return dto
    }
}

struct AVIROUserSignUpResultDTO: Decodable {
    let statusCode: Int
    let userId: String?
    let message: String?
}

struct AVIRONicknameIsDuplicatedCheckDTO: Encodable {
    let nickname: String
}

struct AVIRONicknameIsDuplicatedCheckResultDTO: Codable {
    let statusCode: Int
    let data: AVIRONickNameIsDuplicatedCheckResultDataDTO?
    let message: String?
}

struct AVIRONickNameIsDuplicatedCheckResultDataDTO: Codable {
    let isValid: Bool
    let message: String
}

struct AVIRONicknameChagneableDTO: Encodable {
    let userId: String
    let nickname: String
}
