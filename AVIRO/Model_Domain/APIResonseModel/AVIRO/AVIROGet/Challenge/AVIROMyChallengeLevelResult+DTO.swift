//
//  AVIROMyChallengeLevelResult+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import Foundation

struct AVIROMyChallengeLevelResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROMyChallengeLevelDataDTO?
    let message: String?
}

struct AVIROMyChallengeLevelDataDTO: Decodable {
    let level: Int
    let point: Int
    let pointForNext: Int
    let total: Int
    let userRank: Int
    let image: String
}
