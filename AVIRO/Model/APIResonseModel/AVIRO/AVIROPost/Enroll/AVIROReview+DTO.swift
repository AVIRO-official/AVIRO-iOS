//
//  AVIROComment.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/27.
//

import Foundation

struct AVIROEnrollReviewDTO: Encodable {
    var commentId = UUID().uuidString
    let placeId: String
    let userId: String
    let content: String
}

struct AVIROEditReviewDTO: Encodable {
    let commentId: String
    let content: String
    let userId: String
}

struct AVIRODeleteReveiwDTO: Encodable {
    let commentId: String
    let userId: String
}

struct AVIRORecommendPlaceDTO: Encodable {
    let placeId: String
    let userId: String
}

struct AVIRORecommendPlaceResultDTO: Decodable {
    let statusCode: Int
}
