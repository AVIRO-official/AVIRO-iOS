//
//  LaunchScreenViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/10/03.
//

import UIKit

import Lottie

final class LaunchScreenViewController: UIViewController {
    
    private lazy var aviro: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .launchAVIRO
        
        return imageView
    }()
    
    private var isUpdateRequire: Bool = true {
        didSet {
            if !isUpdateRequire {
                afterLaunchScreenEnd?()
            }
        }
    }
    
    var afterLaunchScreenEnd: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
        
        checkVersion()
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .keywordBlue
    }
    
    private func setupLayout() {
        [
            aviro
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            aviro.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            aviro.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func checkVersion() {
        SystemUtility().latestVersion { [weak self] latestVersion in
            let latestVersion = latestVersion ?? "0.0.0"
            let currentVersion = SystemUtility.appVersion ?? "0.0.0"
            
            let splitLatestVersion = latestVersion.split(separator: ".").map { $0 }
            let splitCurrentVersion = currentVersion.split(separator: ".").map { $0 }
            
            if splitCurrentVersion[0] < splitLatestVersion[0] {
                self?.showUpdateAlert(latestVersion)
                return
            } else {
                if splitCurrentVersion[1] < splitLatestVersion[1] {
                    self?.showUpdateAlert(latestVersion)
                    return
                }
            }
            self?.isUpdateRequire = false
        }
    }
    
    private func showUpdateAlert(_ latestVersion: String) {
        isUpdateRequire = true
        
        let action: AlertAction = (title: "업데이트", style: .default, handler: {
            SystemUtility().openAppStore()
        })
        
        showAlert(
            title: "업데이트 알림",
            message: "어비로의 새로운 버전이 있습니다! \(latestVersion) 버전으로 업데이트 해주세요.",
            actions: [action]
        )
    }
}
