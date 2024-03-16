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
}

protocol TabBarToSubVCDelegate: AnyObject {
    func handleTabBarInteraction(withData data: [String: Any])
}
