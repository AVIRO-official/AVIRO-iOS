//
//  AVIROPostResultDTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/15.
//

import Foundation

// MARK: Output Data
struct AVIROResultDTO: Decodable {
    let statusCode: Int
    let message: String?
}

struct AVIROResultWhenChallengeDTO: Decodable {
    let statusCode: Int
    let message: String?
    let data: AVIROMyChallengeStatusDTO?
}

struct AVIROMyChallengeStatusDTO: Decodable {
    let levelUp: Bool
    let userLevel: Int
}
