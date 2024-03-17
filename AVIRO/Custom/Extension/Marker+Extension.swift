//
//  Marker+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/08.
//

import Foundation

import NMapsMap

extension NMFMarker {
    // TODO: - 함수 분리 필요
    func makeIcon(veganType: VeganType, categoryType: CategoryType) {
        switch veganType {
        case .All:
            switch categoryType {
            case .Bar:
                self.iconImage = MapIcon.allBar.image
            case .Bread:
                self.iconImage = MapIcon.allBread.image
            case .Coffee:
                self.iconImage = MapIcon.allCoffee.image
            case .Restaurant:
                self.iconImage = MapIcon.allRestaurant.image
            }
        case .Some:
            switch categoryType {
            case .Bar:
                self.iconImage = MapIcon.someBar.image
            case .Bread:
                self.iconImage = MapIcon.someBread.image
            case .Coffee:
                self.iconImage = MapIcon.someCoffee.image
            case .Restaurant:
                self.iconImage = MapIcon.someRestaurant.image
            }
        case .Request:
            switch categoryType {
            case .Bar:
                self.iconImage = MapIcon.requestBar.image
            case .Bread:
                self.iconImage = MapIcon.requestBread.image
            case .Coffee:
                self.iconImage = MapIcon.requestCoffee.image
            case .Restaurant:
                self.iconImage = MapIcon.requestRestaurant.image
            }
        }
    }
    
    // TODO: - 함수 분리 필요
    func changeIcon(veganType: VeganType, categoryType: CategoryType, isSelected: Bool) {
        switch veganType {
        case .All:
            switch categoryType {
            case .Bar:
                self.iconImage = isSelected ? MapIcon.allBarClicked.image : MapIcon.allBar.image
            case .Bread:
                self.iconImage = isSelected ? MapIcon.allBreadClicked.image : MapIcon.allBread.image
            case .Coffee:
                self.iconImage = isSelected ? MapIcon.allCoffeeClicked.image : MapIcon.allCoffee.image
            case .Restaurant:
                self.iconImage = isSelected ? MapIcon.allRestaurantClicked.image : MapIcon.allRestaurant.image
            }
        case .Some:
            switch categoryType {
            case .Bar:
                self.iconImage = isSelected ? MapIcon.someBarClicked.image : MapIcon.someBar.image
            case .Bread:
                self.iconImage = isSelected ? MapIcon.someBreadClicked.image : MapIcon.someBread.image
            case .Coffee:
                self.iconImage = isSelected ? MapIcon.someCoffeeClicked.image : MapIcon.someCoffee.image
            case .Restaurant:
                self.iconImage = isSelected ? MapIcon.someRestaurantClicked.image : MapIcon.someRestaurant.image
            }
            
        case .Request:
            switch categoryType {
            case .Bar:
                self.iconImage = isSelected ? MapIcon.requestBarClicked.image : MapIcon.requestBar.image
            case .Bread:
                self.iconImage = isSelected ? MapIcon.requestBreadClicked.image : MapIcon.requestBread.image
            case .Coffee:
                self.iconImage = isSelected ? MapIcon.requestCoffeeClicked.image : MapIcon.requestCoffee.image
            case .Restaurant:
                self.iconImage = isSelected ? MapIcon.requestRestaurantClicked.image : MapIcon.requestRestaurant.image
            }
        }
    }
    
    func changeStarIcon(veganType: VeganType, isSelected: Bool) {
        switch veganType {
        case .All:
            self.iconImage = isSelected ?
            MapIcon.allMapStarClicked.image
            :
            MapIcon.allMapStar.image
            
        case .Some:
            self.iconImage = isSelected ?
            MapIcon.someMapStarClicked.image
            :
            MapIcon.someMapStar.image
            
        case .Request:
            self.iconImage = isSelected ?
            MapIcon.requestMapStarClicked.image
            :
            MapIcon.requestMapStar.image
        }
    }
}
