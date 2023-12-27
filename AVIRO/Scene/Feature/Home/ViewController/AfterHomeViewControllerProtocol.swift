//
//  AfterHomeViewControllerProtocol.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/27.
//

import UIKit

protocol AfterHomeViewControllerProtocol: AnyObject {
    func showRecommendPlaceAlert(with model: AVIROEnrollReviewResultDTO)
    func showLevelUpAlert(with level: Int)
}
