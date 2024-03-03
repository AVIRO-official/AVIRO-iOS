//
//  MarkerModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/08.
//

import UIKit

import NMapsMap

// MARK: - Map Marker
enum VeganType {
    case All
    case Some
    case Request
}

// MARK: - Map Marker + Category
enum CategoryType {
    case Bar
    case Bread
    case Coffee
    case Restaurant
    
    init?(with value: String) {
        switch value {
        case "식당": self = .Restaurant
        case "카페": self = .Coffee
        case "술집": self = .Bar
        case "빵집": self = .Bread
        default: return nil
        }
    }
    
    var title: String {
        switch self {
        case .Bar:
            "술집"
        case .Bread:
            "빵집"
        case .Coffee:
            "카페"
        case .Restaurant:
            "식당"
        }
    }
}

// MARK: - Map Icon
enum MapIcon {
    // All
    case allBar
    case allBarClicked
    
    case allBread
    case allBreadClicked
    
    case allCoffee
    case allCoffeeClicked
    
    case allRestaurant
    case allRestaurantClicked

    case allMapStar
    case allMapStarClicked
    
    // Some
    case someBar
    case someBarClicked
    
    case someBread
    case someBreadClicked
    
    case someCoffee
    case someCoffeeClicked
    
    case someRestaurant
    case someRestaurantClicked
    
    case someMapStar
    case someMapStarClicked
    
    // Request
    case requestBar
    case requestBarClicked
    
    case requestBread
    case requestBreadClicked
    
    case requestCoffee
    case requestCoffeeClicked
    
    case requestRestaurant
    case requestRestaurantClicked
    
    case requestMapStar
    case requestMapStarClicked

    // MARK: - Map Icon Image
    private static let allBarImage = NMFOverlayImage(image: .allDefaultBar)
    private static let allBarClickedImage = NMFOverlayImage(image: .allClickedBar)
    
    private static let allBreadImage = NMFOverlayImage(image: .allDefaultBread)
    private static let allBreadClickedImage = NMFOverlayImage(image: .allClickedBread)
    
    private static let allCoffeeImage = NMFOverlayImage(image: .allDefaultCoffee)
    private static let allCoffeeClickedImage = NMFOverlayImage(image: .allClickedCoffee)
    
    private static let allRestaurantImage = NMFOverlayImage(image: .allDefaultRestaurant)
    private static let allRestaurantClickedImage = NMFOverlayImage(image: .allClickedRestaurant)
    
    private static let someBarImage = NMFOverlayImage(image: .someDefaultBar)
    private static let someBarClickedImage = NMFOverlayImage(image: .someClickedBar)
    
    private static let someBreadImage = NMFOverlayImage(image: .someDefaultBread)
    private static let someBreadClickedImage = NMFOverlayImage(image: .someClickedBread)
    
    private static let someCoffeeImage = NMFOverlayImage(image: .someDefaultCoffee)
    private static let someCoffeeClickedImage = NMFOverlayImage(image: .someClickedCoffee)
    
    private static let someRestaurantImage = NMFOverlayImage(image: .someDefaultRestaurant)
    private static let someRestaurantClickedImage = NMFOverlayImage(image: .someClickedRestaurant)
    
    private static let requestBarImage = NMFOverlayImage(image: .requestDefaultBar)
    private static let requestBarClickedImage = NMFOverlayImage(image: .requestClickedBar)
    
    private static let requestBreadImage = NMFOverlayImage(image: .requestDefaultBread)
    private static let requestBreadClickedImage = NMFOverlayImage(image: .requestClickedBread)
    
    private static let requestCoffeeImage = NMFOverlayImage(image: .requestDefaultCoffee)
    private static let requestCoffeeClickedImage = NMFOverlayImage(image: .requestClickedCoffee)
    
    private static let requestRestaurantImage = NMFOverlayImage(image: .requestDefaultRestaurant)
    private static let requestRestaurantClickedImage = NMFOverlayImage(image: .requestClickedRestaurant)
    
    private static let allMapStarImage = NMFOverlayImage(image: .allIconStar)
    private static let someMapStarImage = NMFOverlayImage(image: .someIconStar)
    private static let requestMapStarImage = NMFOverlayImage(image: .requestIconStar)
    
    private static let allMapStarClickedImage = NMFOverlayImage(image: .allIconStarClicked)
    private static let someMapStarClickedImage = NMFOverlayImage(image: .someIconStarClicked)
    private static let requestMapStarClickedImage = NMFOverlayImage(image: .requestIconStarClicked)

    var image: NMFOverlayImage {
        switch self {
        case .allBar:
            return MapIcon.allBarImage
        case .allBarClicked: 
            return MapIcon.allBarClickedImage
            
        case .allBread: 
            return MapIcon.allBreadImage
        case .allBreadClicked: 
            return MapIcon.allBreadClickedImage
            
        case .allCoffee: 
            return MapIcon.allCoffeeImage
        case .allCoffeeClicked: 
            return MapIcon.allCoffeeClickedImage
            
        case .allRestaurant: 
            return MapIcon.allRestaurantImage
        case .allRestaurantClicked: 
            return MapIcon.allRestaurantClickedImage
            
        case .someBar: 
            return MapIcon.someBarImage
        case .someBarClicked: 
            return MapIcon.someBarClickedImage
            
        case .someBread: 
            return MapIcon.someBreadImage
        case .someBreadClicked: 
            return MapIcon.someBreadClickedImage
            
        case .someCoffee: 
            return MapIcon.someCoffeeImage
        case .someCoffeeClicked: 
            return MapIcon.someCoffeeClickedImage
            
        case .someRestaurant: 
            return MapIcon.someRestaurantImage
        case .someRestaurantClicked: 
            return MapIcon.someRestaurantClickedImage
            
        case .requestBar: 
            return MapIcon.requestBarImage
        case .requestBarClicked: 
            return MapIcon.requestBarClickedImage
            
        case .requestBread: 
            return MapIcon.requestBreadImage
        case .requestBreadClicked: 
            return MapIcon.requestBreadClickedImage
            
        case .requestCoffee: 
            return MapIcon.requestCoffeeImage
        case .requestCoffeeClicked: 
            return MapIcon.requestCoffeeClickedImage
            
        case .requestRestaurant:
            return MapIcon.requestRestaurantImage
        case .requestRestaurantClicked:
            return MapIcon.requestRestaurantClickedImage
            
        case .allMapStar:
            return MapIcon.allMapStarImage
        case .allMapStarClicked:
            return MapIcon.allMapStarClickedImage
            
        case .someMapStar:
            return MapIcon.someMapStarImage
        case .someMapStarClicked:
            return MapIcon.someMapStarClickedImage
            
        case .requestMapStar:
            return MapIcon.requestMapStarImage
        case .requestMapStarClicked:
            return MapIcon.requestMapStarClickedImage
        }
    }
}

// MARK: Map Place didSet 수정 확인
struct MarkerModel: Equatable {
    let placeId: String
    var marker: NMFMarker
    
    // MARK: 수정 중 일때만 Map Place 변경 가능
    // 해당 변수는 지도에 표시될 마커 구분을 위한 변수
    var veganType: VeganType {
        didSet {
            updateMarkerIcon()
        }
    }
    
    var categoryType: CategoryType {
        didSet {
            updateMarkerIcon()
        }
    }
    
    var isStar = false {
        didSet {
            updateMarkerIcon()
        }
    }
    
    var isClicked = false {
        didSet {
            updateMarkerIcon()
        }
    }
    
    // edit할때 isSome, isRequest 중복이 있을 수 있으니 변수 생성
    var isAll = false
    var isSome = false
    var isRequest = false
    
    private func updateMarkerIcon() {
        if isStar {
            marker.changeStarIcon(veganType: veganType, isSelected: isClicked)
        } else {
            marker.changeIcon(veganType: veganType, categoryType: categoryType, isSelected: isClicked)
        }
    }
}
