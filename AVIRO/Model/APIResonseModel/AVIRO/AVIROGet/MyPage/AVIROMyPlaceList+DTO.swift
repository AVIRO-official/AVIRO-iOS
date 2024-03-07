//
//  AVIROMyPlaceList+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import Foundation

struct AVIROMyPlaceListDTO: Decodable {
    let statusCode: Int
    let data: AVIROMyPlaceListDataDTO?
    let message: String?
}

struct AVIROMyPlaceListDataDTO: Decodable {
    let placeList: [AVIROMyPlaceDataDTO]?
}

struct AVIROMyPlaceDataDTO: Decodable {
    let placeId: String
    let title: String
    let category: String
    let shortAddress: String
    let allVegan: Bool
    // 파라미터 이름 변경 필요
    let someMenuVegan: Bool
    let ifRequestVegan: Bool
    let menu: String
    /// '외 n개 메뉴'
    let menuCountExceptOne: Int
    let createdBefore: String
    
    func toDomain() -> MyPlaceCellModel {
        MyPlaceCellModel(with: self)
    }
}
