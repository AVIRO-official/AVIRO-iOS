//
//  DefaultEnum.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/20.
//

import UIKit

import NMapsMap

enum APP: String {
    case appId = "6449352804"
    case bundleId = "SeonghunJeon.VeganRestaurant"
}

// MARK: UserDefaults Key
enum UDKey: String {
    case tutorial
    case tutorialHome
    case tutorialChallenge
    case hideUntil
    case timeForUpdate
    
    case loginType
}

enum LoginTypeKey: String {
    case none
    case apple
    case google
    case kakao
    case naver
}

// MARK: NotificationCenter Name
enum NotiName: String {
    case afterMainSearch
}

// MARK: Keychain
enum KeychainKey: String {
    case appleRefreshToken
    
    case refreshToken
    case userID
}

// MARK: TableViewCell Identifier
enum TVIdentifier: String {
    case termsTableCell
    case homeSearchPlaceTableCell
    case homeSearchHistoryTableCell
}

// MARK: CollectionViewCell Identifier
enum CVIdentifier: String {
    case tutorialTopCell
    case tutorialBottomCell
}

// MARK: 이용 약관
enum Policy: String {
    case termsOfService = "https://bronzed-fowl-e81.notion.site/85cfe934602142949a18c2a5ac0ea641?pvs=4"
    case privacy = "https://bronzed-fowl-e81.notion.site/6722cb9f4d334987bc6683400ed794b9?pvs=4"
    case location =  "https://bronzed-fowl-e81.notion.site/42daafcaf14945eca8f2c2b3f1fe5c43?pvs=4"
    case thanksto = "https://bronzed-fowl-e81.notion.site/8b6eb5da64054f7db1c307dd5d057317?pvs=4"
}

// MARK: Defalut Coordinate
/// 광안리 해수욕장
enum DefaultCoordinate: Double {
    case lat = 35.153354
    case lng = 129.118924
}

// MARK: Gender 
enum Gender: String, Codable {
    case male
    case female
    case other
    
    init?(rawValue: String) {
        switch rawValue {
        case "남자":
            self = .male
        case "여자":
            self = .female
        case "기타":
            self = .other
        default:
            return nil
        }
    }
}

// MARK: Vegan Option
enum VeganOption {
    case all
    case some
    case request
    
    var buttontitle: String {
        switch self {
        case .all:
            return "모든 메뉴가\n비건"
        case .some:
            return "일부 메뉴만\n비건"
        case .request:
            return "비건 메뉴로\n요청 가능"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .all:
            return UIImage.allOptionButton
        case .some:
            return UIImage.someOptionButton
        case .request:
            return UIImage.requestOptionButton
        }
    }
}

// MARK: Place Category
enum PlaceCategory: String {
    case restaurant
    case cafe
    case bakery
    case bar
    
    var title: String {
        switch self {
        case .restaurant: return "식당"
        case .cafe: return "카페"
        case .bakery: return "빵집"
        case .bar: return "술집"
        }
    }
    
    init?(title: String) {
        switch title {
        case "식당": self = .restaurant
        case "카페": self = .cafe
        case "빵집": self = .bakery
        case "술집": self = .bar
        default: return nil
        }
    }
}

// MARK: MenuType
enum MenuType: String {
    case vegan
    case needToRequset
}

// MARK: Operation State
enum OperationState: String {
    case beforeOpening = "영업전"
    case operating = "영업중"
    case closed = "영업종료"
    case breakTime = "휴식시간"
    case holiday = "휴무일"
    case noInfoToday = "오늘 정보 없음"
    
    var color: UIColor {
        switch self {
        case .breakTime, .holiday:
            return .warning
        case .noInfoToday:
            return .gray2
        default:
            return .gray0
        }
    }
}

// MARK: Day
enum Day: String {
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "토"
    case sun = "일"
}

// MARK: Place View State
enum PlaceViewState {
    case noShow
    case popup
    case slideup
    case full
}

// MARK: Report Place
enum AVIROReportPlaceType: String {
    case noPlace = "없어짐"
    case noVegan = "비건없음"
    case dubplicatedPlace = "중복등록"
    
    var code: Int {
        switch self {
        case .noPlace:
            return 1
        case .noVegan:
            return 2
        case .dubplicatedPlace:
            return 3
        }
    }
}

// MARK: Report Review Type
enum AVIROReportReviewType: String, CaseIterable {
    case profanity = "욕설/비방/차별/혐오 후기예요."
    case advertisement = "홍보/영리목적 후기예요."
    case illegalInfo = "불법 정보 후기예요."
    case obscene = "음란/청소년 유해 후기예요."
    case personalInfo = "개인 정보 노출/유포/거래를 한 후기예요."
    case spam = "도배/스팸 후기예요."
    case others = "기타"
    
    var code: Int {
        switch self {
        case .profanity:
            return 1
        case .advertisement:
            return 2
        case .illegalInfo:
            return 3
        case .obscene:
            return 4
        case .personalInfo:
            return 5
        case .spam:
            return 6
        case .others:
            return 7
        }
    }
}
