//
//  ImagesStorageInterface.swift
//  AVIRO
//
//  Created by 전성훈 on 11/11/24.
//

import Foundation

protocol ImagesStorageInterface {
    
    var capacity: UInt { get }
    
    func getData(key: String, completion: @escaping (Data?) -> Void)
    func setData(key: String, value: Data)
}
