//
//  AVIROWellcome+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/16.
//

import Foundation

struct AVIROWellcomeDTO: Decodable {
    let statusCode: Int
    let data: AVIROWellcomeDataDTO?
    let message: String?
}

struct AVIROWellcomeDataDTO: Decodable {
    let imageUrl: String
}
