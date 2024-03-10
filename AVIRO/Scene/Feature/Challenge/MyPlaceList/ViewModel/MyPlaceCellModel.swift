//
//  MyPlaceCellModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

// MARK: - 추후 모듈화할때 Domain으로 옮길 예정

import Foundation

struct MyPlaceCellModel {
    let placeId: String
    let category: CategoryType
    let veganType: VeganType
    let title: String
    let address: String
    let menu: String
    let menuCount: Int
    let createdBefore: String
    
    init(with model: AVIROMyPlaceDataDTO) {
        self.placeId = model.placeId
        
        self.category = CategoryType(with: model.category) ?? .Restaurant
        
        if model.allVegan {
            self.veganType = .All
        } else if model.someMenuVegan {
            self.veganType = .Some
        } else {
            self.veganType = .Request
        }
        
        self.title = model.title
        self.address = model.shortAddress
        self.menu = model.menu
        self.menuCount = model.menuCountExceptOne
        self.createdBefore = model.createdBefore.relativeDateString()
    }
}
