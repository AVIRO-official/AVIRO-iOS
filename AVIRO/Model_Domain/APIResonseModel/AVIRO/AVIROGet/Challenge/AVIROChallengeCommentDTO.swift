//
//  AVIROChallengeCommentDTO.swift
//  AVIRO
//
//  Created by Jeon on 2024/03/15.
//

import Foundation

struct AVIROChallengeCommentDTO: Decodable {
    let statusCode: Int
    let data: AVIROChallengeCommentDataDTO
}

struct AVIROChallengeCommentDataDTO: Decodable {
    let comment: String
}
