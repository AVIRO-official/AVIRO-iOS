//
//  AVIROMyCommentList+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

struct AVIROMyCommentListDTO: Decodable {
    let statusCode: Int
    let data: AVIROMyCommentListDataDTO?
    let message: String?
}

struct AVIROMyCommentListDataDTO: Decodable {
    let commentList: [AVIROMyCommentDataDTO]?
}

struct AVIROMyCommentDataDTO: Decodable {
    let commentId: String
    let placeId: String
    let title: String
    let category: String
    let allVegan: Bool
    let someMenuVegan: Bool
    let ifRequestVegan: Bool
    let content: String
    let createdBefore: String
    
    func toDomain() -> MyCommentCellModel {
        MyCommentCellModel(with: self)
    }
}
