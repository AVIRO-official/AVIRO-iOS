//
//  ViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/21.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(with input: Input) -> Output
}
