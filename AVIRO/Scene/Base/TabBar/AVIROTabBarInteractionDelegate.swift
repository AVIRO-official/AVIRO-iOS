//
//  AVIROInteractionDelegate.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/10.
//

import Foundation

struct TabBarKeys {
    static let placeId = "placeId"
}

protocol TabBarInteractionDelegate: AnyObject {
    func handleTabBarInteraction(withKey key: String?, value: String?)
}
