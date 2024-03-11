//
//  AVIROTabBarSettingDelegate.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/10.
//

import Foundation

protocol TabBarSettingDelegate: AnyObject {
    var selectedIndex: Int { get set }
    var isHidden: (isHidden: Bool, isSameNavi: Bool) { get set }
    
    func setSelectedIndex(_ index: Int, withData data: [String: Any])
    func activeBlurEffectView(with active: Bool)
}
