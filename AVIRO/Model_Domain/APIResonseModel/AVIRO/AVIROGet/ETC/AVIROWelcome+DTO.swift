//
//  AVIROWelcome+DTO.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/16.
//

import Foundation

struct AVIROWelcomeDTO: Decodable {
    let statusCode: Int
    let data: [AVIROWelcomeDataDTO]?
    let message: String?
}

struct AVIROWelcomeDataDTO: Decodable {
    let title: String
    let imageURL: String
    let url: String?
    let event: String?
    let buttonColor: String
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "image_url"
        case url
        case event
        case buttonColor = "button_color"
        case order
    }
    
    func toDomain() -> WelcomePopup {
        let imageURL = URL(string: imageURL)!
        
        let url = self.url.flatMap { URL(string: $0) }
        
        let event: WelcomePopupEvent? = {
            guard let eventString = self.event else { return nil }
            
            switch eventString {
            case "MTCH":
                return .MTCH
            default:
                return nil
            }
        }()
        
        return WelcomePopup(
            title: title,
            imageURL: imageURL,
            url: url,
            event: event,
            buttonColor: buttonColor
        )
    }
}
