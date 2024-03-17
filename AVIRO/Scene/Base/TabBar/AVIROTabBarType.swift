//
//  TabBarType.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/10.
//

import Foundation
import UIKit.UIColor

enum TabBarType: CaseIterable {
    case home
    case plus
    case challenge
    
    init?(title: String) {
        switch title {
        case "홈":
            self = .home
        case "등록하기":
            self = .plus
        case "챌린지":
            self = .challenge
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .plus: return "등록하기"
        case .challenge: return "챌린지"
        }
    }
    
    var normalColor: UIColor {
        switch self {
        case .home: return .gray4
        case .plus: return .gray4
        case .challenge: return .gray4
        }
    }
    
    var selectedColor: UIColor {
        switch self {
        case .home: return .keywordBlue
        case .plus: return .keywordBlue
        case .challenge: return .keywordBlue
        }
    }
    
    var icon: UIImage {
        switch self {
        case .home: return UIImage.homeTab
        case .plus: return UIImage.plusTab
        case .challenge: return UIImage.tropyTab
        }
    }
}
