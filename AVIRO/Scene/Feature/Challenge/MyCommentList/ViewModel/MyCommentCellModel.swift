//
//  MyCommentCellModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

import Foundation

struct MyCommentCellModel {
    let commentId: String
    let placeId: String
    
    let category: CategoryType
    let veganType: VeganType
    
    let title: String
    let content: String

    let createdBefore: String

    init(with model: AVIROMyCommentDataDTO) {
        self.commentId = model.commentId
        self.placeId = model.placeId
        
        self.category = CategoryType(with: model.category) ?? .Restaurant
        
        if model.allVegan {
            self.veganType = .All
        } else if model.someMenuVegan {
            self.veganType = .Some
        } else {
            self.veganType = .Request
        }
        
        self.title = model.title
        self.content = model.content
        
        self.createdBefore = model.createdBefore.relativeDateString()
    }
}
