//
//  PlaceModelBeforeMatchedAVIRO.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/05.
//

import Foundation

struct AVIROBeforeComparePlaceDTO: Encodable {
    let placeArray: [AVIROForMatchedModel]
}

struct AVIROForMatchedModel: Encodable {
    let title: String
    let x: Double
    let y: Double
}

struct AVIROAfterComparePlaceDTO: Decodable {
    let statusCode: Int
    let message: String?
    let data: AVIROAfterMatchedModelList?
}

struct AVIROAfterMatchedModelList: Decodable {
    let placeList: [AVIROAfterMatchedModel]
}

struct AVIROAfterMatchedModel: Decodable {
    let index: Int
    let placeId: String
    let allVegan: Bool
    let someMenuVegan: Bool
    let ifRequestVegan: Bool
}
