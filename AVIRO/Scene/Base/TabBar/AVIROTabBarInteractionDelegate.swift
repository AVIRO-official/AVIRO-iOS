//
//  AVIROInteractionDelegate.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/10.
//

import Foundation

struct TabBarKeys {
    static let placeId = "placeId"
    static let showReview = "review"
    static let source = "source"
}

enum TabBarSourceValues: String {
    case placeList
    case commentList
    case bookmarkList
}

protocol TabBarToSubVCDelegate: AnyObject {
    func handleTabBarInteraction(withData data: [String: Any])
}
