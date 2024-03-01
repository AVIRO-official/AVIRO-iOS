//
//  AVIROMyCommentList+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

struct AVIROMyCommentListDTO: Decodable {
    let statusCode: Int
    let data: AVIROMyPlaceListDataDTO?
    let message: String?
}

struct AVIROMyCommentListDataDTO: Decodable {
    let placeList: [AVIROMyPlaceDataDTO]?
}

struct AVIROMyCommentDataDTO: Decodable {
    let commentId: String
    let title: String
    let category: String
    let allVegan: Bool
    let someMenuVegan: Bool
    let ifRequestVegan: Bool
    let content: String
}
