//
//  AVIROBookmarkModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/23.
//

import Foundation

struct AVIROBookmarkModelResultDTO: Decodable {
    let statusCode: Int
    let data: AVIROBookmarkModelResultDataDTO?
    let message: String?
}

struct AVIROBookmarkModelResultDataDTO: Decodable {
    let bookmarks: [String]
}
