//
//  AVIROPlaceReportCheckDTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/10.
//

import Foundation

struct AVIROPlaceReportCheckDTO {
    let placeId: String
    let userId: String
}

struct AVIROPlaceReportCheckResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROPlaceReportCheckResultDataDTO?
    let message: String?
}

struct AVIROPlaceReportCheckResultDataDTO: Decodable {
    let reported: Bool
}
