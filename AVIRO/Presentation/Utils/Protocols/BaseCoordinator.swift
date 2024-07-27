//
//  BaseCoordinator.swift
//  AVIRO
//
//  Created by 전성훈 on 5/10/24.
//

import UIKit

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    
    init() { }
    
    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        printIfDebug("---- start Coordinator: \(self) ----")
    }
}
