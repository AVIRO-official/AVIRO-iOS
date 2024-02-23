//
//  ColorCustom.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/04.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        var hexValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&hexValue)

        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: MAIN
    /// GREEN
    static let all = UIColor(named: "GREEN")!
    /// ORANGE
    static let some = UIColor(named: "ORANGE")!
    /// YELLOW
    static let request = UIColor(named: "YELLOW")!
    /// NAVY
    static let main = UIColor(named: "COBALT")!
    /// RED
    static let warning = UIColor(named: "RED")!
    /// BG NAVY
    static let bgNavy = UIColor(named: "BG NAVY")!
    /// BG RED
    static let bgRed = UIColor(named: "BG RED")!
    /// ChangeButtonColor
    static let keywordBlue = UIColor(named: "KEYWORD_BLUE")!
    
    // MARK: Background
    /// 본문, 작성 후 텍스트 (Active)
    static let gray0 = UIColor(named: "GRAY0")!
    /// 부제
    static let gray1 = UIColor(named: "GRAY1")!
    /// 부제, 인풋창 내 아이콘
    static let gray2 = UIColor(named: "GRAY2")!
    /// 작성 전 텍스트 (Default)
    static let gray3 = UIColor(named: "GRAY3")!
    /// 누르기 전 버튼 (Default)
    static let gray4 = UIColor(named: "GRAY4")!
    /// 구분 선, 인풋 창 아웃라인
    static let gray5 = UIColor(named: "GRAY5")!
    /// 인풋창 배경
    static let gray6 = UIColor(named: "GRAY6")!
    /// 모든 화이트
    static let gray7 = UIColor(named: "GRAY7")!
    
    static let tutorialBackgroud = UIColor(red: 0.96, green: 0.99, blue: 1, alpha: 1)
    static let launchTitleColor = UIColor(red: 0.83, green: 0.89, blue: 1, alpha: 1)
    
    static let loginTitleColor = UIColor(red: 0.57, green: 0.69, blue: 0.92, alpha: 1)
    
    static let challengeImageBorder = UIColor(named: "ChallengeImageBorder")!
}
