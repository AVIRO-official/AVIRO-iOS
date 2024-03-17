//
//  FinalRegistrationViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/13.
//

import UIKit

// MARK: Text
private enum Text: String {
    case title = "가입 완료\n환영합니다!"
    case next = "어비로 바로 시작하기"
}

// MARK: Layout
private enum Layout {
    enum Margin: CGFloat {
        case small = 10
        case medium = 20
        case large = 30
        case largeToView = 40
    }
    
    enum Size: CGFloat {
        case nextButtonHeight = 50
    }
}

final class FinalRegistrationViewController: UIViewController {
    
    // MARK: UI Property Definitions
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = Text.title.rawValue
        label.textColor = .main
        label.textAlignment = .center
        label.font = CFont.font.bold24
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var finalButton: NextPageButton = {
        let button = NextPageButton()
        
        button.setTitle(Text.next.rawValue, for: .normal)
        button.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    // MARK: Set up func
    private func setupLayout() {
        [
            titleLabel,
            finalButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            
            finalButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Layout.Margin.largeToView.rawValue
            ),
            finalButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.Margin.medium.rawValue
            ),
            finalButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.Margin.medium.rawValue
            ),
            finalButton.heightAnchor.constraint(
                equalToConstant: Layout.Size.nextButtonHeight.rawValue
            )
        ])
    }
    
    private func setupAttribute() {
        view.backgroundColor = .gray7
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: UI Interactions
    @objc func buttonTapped() {
        let tabBarVC = AVIROTabBarController.create(
            amplitude: AmplitudeUtility(),
            type: [
                TabBarType.home,
                TabBarType.plus,
                TabBarType.challenge
            ]
        )
        
        tabBarVC.selectedIndex = 0
        
        navigationController?.pushViewController(tabBarVC, animated: true)
        //        let viewController = TabBarViewController()
        //
        //        navigationController?.pushViewController(
        //            viewController,
        //            animated: true
        //        )
    }
}
