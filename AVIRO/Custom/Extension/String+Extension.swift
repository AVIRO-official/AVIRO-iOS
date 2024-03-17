//
//  String.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/17.
//

import UIKit

extension String {
    // MARK: Nickname 갯수 제한 8개
    var limitedNickname: String {
        if self.count > 8 {
            let startIndex = self.startIndex
            let endIndex = self.index(startIndex, offsetBy: 7)
            return String(self[startIndex...endIndex])
        }
        return self
    }
    
    // MARK: Text m/k 변환
    /// Text m/k 변환
    func convertDistanceUnit() -> String {
        guard let number = Double(self) else { return "" }
        
        if number >= 1000 {
            return String(format: "%.1fkm", number / 1000) 
        } else {
            return "\(Int(number))m"
        }
    }
    
    // MARK: 자동 ',' 찍기
    /// decimal string 변환
    func formatNumber() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = .current
        
        let noCommaString = self.replacingOccurrences(of: ",", with: "")
        
        if let number = Int(noCommaString) {
            return numberFormatter.string(
                from: NSNumber(value: number)
            )
        }
        return self
    }

    // MARK: Text 색상 변경
    func changeColor(changedText: String) -> NSMutableAttributedString? {
        if let range = self.range(of: changedText, options: []) {
            let attributedText = NSMutableAttributedString(string: self)
            attributedText.addAttribute(
                .foregroundColor,
                value: UIColor.keywordBlue,
                range: NSRange(range, in: self)
            )
            
            return attributedText
        }
        return nil
    }
    
    // MARK: URL Check
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func dateFormCustomString() -> Date? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.date(from: self)
    }
    
    // MARK: 전날 계산기
    func relativeDateString() -> String {
        guard let date = self.dateFormCustomString() else { return self }

        let calender = Calendar.current
        let now = Date()
        let startOfDate = calender.startOfDay(for: date)
        
        let components = calender.dateComponents([.day, .weekOfYear, .month, .year], from: startOfDate, to: now)

        var result = "오늘"
        
        if let day = components.day, day > 0 {
            result = "\(day)일 전"
        }
        
        if let week = components.weekOfYear, week > 0 {
            result = "\(week)주 전"
        }
        
        if let month = components.month, month > 0 {
            result = "\(month)개월 전"
        } 
        
        if let year = components.year, year > 0 {
            result = "\(year)년 전"
        }
        
        return result
    }
}
