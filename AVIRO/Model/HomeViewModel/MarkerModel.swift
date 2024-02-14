//
//  MarkerModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/08.
//

import UIKit

import NMapsMap

// MARK: Map Marker
enum MapPlace {
    case All
    case Some
    case Request
}

enum MapIcon {
    case allMap
    case allMapClicked
    case allMapStar
    case allMapStarClicked
    
    case someMap
    case someMapClicked
    case someMapStar
    case someMapStarClicked
    
    case requestMap
    case requestMapClicked
    case requestMapStar
    case requestMapStarClicked
    
    private static let allMapImage = NMFOverlayImage(image: .allIcon)
    private static let someMapImage = NMFOverlayImage(image: .someIcon)
    private static let requestMapImage = NMFOverlayImage(image: .requestIcon)
    
    private static let allMapClickedImage = NMFOverlayImage(image: .allIconClicked)
    private static let someMapClickedImage = NMFOverlayImage(image: .someIconClicked)
    private static let requestMapClickedImage = NMFOverlayImage(image: .requestIconClicked)
    
    private static let allMapStarImage = NMFOverlayImage(image: .allIconStar)
    private static let someMapStarImage = NMFOverlayImage(image: .someIconStar)
    private static let requestMapStarImage = NMFOverlayImage(image: .requestIconStar)
    
    private static let allMapStarClickedImage = NMFOverlayImage(image: .allIconStarClicked)
    private static let someMapStarClickedImage = NMFOverlayImage(image: .someIconStarClicked)
    private static let requestMapStarClickedImage = NMFOverlayImage(image: .requestIconStarClicked)
    
    var image: NMFOverlayImage {
        switch self {
        case .allMap:
            return MapIcon.allMapImage
        case .allMapClicked:
            return MapIcon.allMapClickedImage
            
        case .someMap:
            return MapIcon.someMapImage
        case .someMapClicked:
            return MapIcon.someMapClickedImage
            
        case .requestMap:
            return MapIcon.requestMapImage
        case .requestMapClicked:
            return MapIcon.requestMapClickedImage
            
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
    var mapPlace: MapPlace {
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
            marker.changeStarIcon(mapPlace, isClicked)
        } else {
            marker.changeIcon(mapPlace, isClicked)
        }
    }
}
