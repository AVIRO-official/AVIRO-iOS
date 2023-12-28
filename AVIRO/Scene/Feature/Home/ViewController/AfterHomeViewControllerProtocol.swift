//
//  AfterHomeViewControllerProtocol.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/27.
//

import UIKit

protocol AfterHomeViewControllerProtocol: AnyObject {
    func showRecommendPlaceAlert(with model: (AfterWriteReviewModel, Bool))
    func showLevelUpAlert(with level: Int)
}
