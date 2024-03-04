//
//  MyPlaceCellModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

// Clean Architecture 적용 시 Domain으로 옮길 예정

import Foundation

struct MyPlaceCellModel {
    let category: CategoryType
    let all: Bool
    let some: Bool
    let request: Bool
    let title: String
    let address: String
    let menu: String
    let menuCount: String
    let time: String
}
