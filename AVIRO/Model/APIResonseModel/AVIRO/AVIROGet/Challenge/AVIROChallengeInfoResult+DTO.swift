//
//  AVIROChallengeInfo.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import Foundation

struct AVIROChallengeInfoDTO: Decodable {
    let statusCode: Int
    let data: AVIROChallengeInfoDataDTO?
    let message: String?
}

struct AVIROChallengeInfoDataDTO: Decodable {
    let period: String
    let title: String
}
