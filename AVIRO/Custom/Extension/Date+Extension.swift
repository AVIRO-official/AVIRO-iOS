//
//  Date+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 9/18/24.
//

import Foundation

extension Date {
    func toString2(format: String = "yyyy-MM-dd HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func toSimpleDateString() -> String {
        return toString2(format: "yyyy-MM-dd")
    }
}

