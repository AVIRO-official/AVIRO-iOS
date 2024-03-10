//
//  UINavigationController+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/09.
//

import UIKit

extension UINavigationController {
    func clearNavigationStackExceptRoot() {
        if let rootViewController = self.viewControllers.first {
            self.viewControllers = [rootViewController]
        }
    }
}
