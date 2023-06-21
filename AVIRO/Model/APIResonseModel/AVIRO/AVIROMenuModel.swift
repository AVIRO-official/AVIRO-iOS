//
//  AVIROMenuModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/21.
//

import Foundation

struct AVIROMenuModel: Decodable {
    let status: Int
    let data: MenuData
}

struct MenuData: Decodable {
    let menuArray: [MenuArray]
}
