//
//  WelcomePopups.swift
//  AVIRO
//
//  Created by 전성훈 on 9/19/24.
//

import Foundation

enum WelcomePopupEvent {
    case MTCH
}

struct WelcomePopup {
    let title: String
    let imageURL: URL
    let url: URL?
    let event: WelcomePopupEvent?
    let buttonColor: String
}
