//
//  AVIROTabBarController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import UIKit

enum TabBarType: CaseIterable {
    case home
    case plus
    case challenge
    
    init?(title: String) {
        switch title {
        case "홈":
            self = .home
        case "등록하기":
            self = .plus
        case "챌린지":
            self = .challenge
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .plus: return "등록하기"
        case .challenge: return "챌린지"
        }
    }
    
    var normalColor: UIColor {
        switch self {
        case .home: return .gray4
        case .plus: return .gray0
        case .challenge: return .gray4
        }
    }
    
    var selectedColor: UIColor {
        switch self {
        case .home: return .keywordBlue
        case .plus: return .gray0
        case .challenge: return .keywordBlue
        }
    }
    
    var icon: UIImage {
        switch self {
        case .home: return UIImage.homeTab
        case .plus: return UIImage.plusTab
        case .challenge: return UIImage.tropyTab
        }
    }
}

protocol TabBarDelegate: AnyObject {
    var selectedIndex: Int { get set }
    var isHidden: (isHidden: Bool,isSameNavi: Bool) { get set }
}

final class AVIROTabBarController: UIViewController, TabBarDelegate {
    private lazy var viewControllers: [UIViewController] = []
    
    private lazy var buttons: [TabBarButton] = []
    private var types: [TabBarType] = []
    
    private lazy var tabBarView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        
        return view
    }()
    
    private lazy var bottomInsetView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        
        return view
    }()
    
    var selectedIndex: Int = 0 {
        willSet {
            previousIndex = selectedIndex
        }
        didSet {
            if selectedIndex == 1 {
                isHidden = (true, false)
            } else {
                isHidden = (false, false)
            }
            
            updateView()
        }
    }
    
    var isHidden: (isHidden: Bool,isSameNavi: Bool) = (false,true) {
        didSet {
            print(isHidden)
            tabBarView.isHidden = isHidden.isHidden
            bottomInsetView.isHidden = isHidden.isHidden
            
            if isHidden.isSameNavi {
                setupViewLayoutChange()
            }
        }
    }
    
    private var previousIndex = 0
    
    private var selectedVCBottomUponTabViewConstraint: NSLayoutConstraint?
    private var selectedVCBottomUponViewBottom: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    func setViewControllers(with types: [TabBarType]) {
        
        self.types = types
        types.forEach { tabBarType in
            switch tabBarType {
            case .home:
                let vc = HomeViewController()
                vc.tabBarDelegate = self
                
                let navigationVC = UINavigationController(rootViewController: vc)
                viewControllers.append(navigationVC)
            case .plus:
                let vc = EnrollPlaceViewController()
                vc.tabBarDelegate = self
                
                let navigationVC = UINavigationController(rootViewController: vc)
                viewControllers.append(navigationVC)
            case .challenge:
                let viewModel = ChallengeViewModel()
                let vc = ChallengeViewController.create(with: viewModel)
                vc.tabBarDelegate = self
                
                let navigationVC = UINavigationController(rootViewController: vc)
                viewControllers.append(navigationVC)
            }
        }
    }
    
    private func setupLayout() {
        [
            tabBarView,
            bottomInsetView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: CGFloat.tabBarHeight),
            
            bottomInsetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomInsetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomInsetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomInsetView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor)
        ])
        
        setupButtons()
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .clear
    }
    
    private func setupButtons() {
        let buttonWidth = view.bounds.width / CGFloat(types.count)
        
        for (index, type) in types.enumerated() {
            let button = TabBarButton(tabBarType: type)
            button.tag = index
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            
            tabBarView.addSubview(button)
            buttons.append(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: buttonWidth * CGFloat(index)
                ),
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: CGFloat.tabBarHeight)
            ])
        }
    }
    
    private func updateView() {
        deleteView()
        setupView()
        
        buttons.forEach {
            $0.isSelected = ($0.tag == selectedIndex)
        }
    }
    
    private func deleteView() {
        let previousVC = viewControllers[previousIndex]
        
//        selectedVCBottomUponViewBottom = nil
//        selectedVCBottomUponTabViewConstraint = nil
        previousVC.remove()
    }
    
    private func setupView() {
        let selectedVC = viewControllers[selectedIndex]
        
        self.addChild(selectedVC)
        
        selectedVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(selectedVC.view, belowSubview: tabBarView)
        
        NSLayoutConstraint.activate([
            selectedVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            selectedVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            selectedVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        selectedVCBottomUponTabViewConstraint = selectedVC.view.bottomAnchor.constraint(equalTo: tabBarView.topAnchor)
        selectedVCBottomUponViewBottom = selectedVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        if isHidden.isHidden {
            selectedVCBottomUponTabViewConstraint?.isActive = false
            selectedVCBottomUponViewBottom?.isActive = true
        } else {
            selectedVCBottomUponViewBottom?.isActive = false
            selectedVCBottomUponTabViewConstraint?.isActive = true
        }
    }
    
    private func setupViewLayoutChange() {
        if isHidden.isHidden {
            selectedVCBottomUponTabViewConstraint?.isActive = false
            selectedVCBottomUponViewBottom?.isActive = true
        } else {
            selectedVCBottomUponViewBottom?.isActive = false
            selectedVCBottomUponTabViewConstraint?.isActive = true
        }
    }
    
    @objc private func tabBarButtonTapped(_ sender: TabBarButton) {
        selectedIndex = sender.tag
    }
}
