//
//  AVIROViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 5/10/24.
//

import Foundation

protocol CoordinatorActions: AnyObject { }

protocol AVIROViewModel {
    associatedtype CoordinatorActions
    
    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output
}
