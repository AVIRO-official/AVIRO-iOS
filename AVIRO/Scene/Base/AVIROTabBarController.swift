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
        case .plus: return .gray4
        case .challenge: return .gray4
        }
    }
    
    var selectedColor: UIColor {
        switch self {
        case .home: return .keywordBlue
        case .plus: return .keywordBlue
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
    var isHidden: (isHidden: Bool, isSameNavi: Bool) { get set }
    
    func activeBlurEffectView(with active: Bool)
}

final class AVIROTabBarController: UIViewController, TabBarDelegate {
    private lazy var viewControllers: [UINavigationController] = []
    
    private lazy var buttons: [TabBarButton] = []
    private var types: [TabBarType] = []
    
    private lazy var tabBarView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 3.0
        view.layer.shadowColor = UIColor.gray0.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        
        return view
    }()
    
    private lazy var bottomInsetView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        
        return view
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        view.effect = blurEffect
        view.alpha = 0.6
        
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
    
    var isHidden: (isHidden: Bool, isSameNavi: Bool) = (false, true) {
        didSet {
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
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    func setViewControllers(with types: [TabBarType]) {
        
        self.types = types
        let home = HomeViewController()
        
        let enroll = EnrollPlaceViewController()
        
        let challengeViewModel = ChallengeViewModel()
        let challenge = ChallengeViewController.create(with: challengeViewModel)
        
        home.tabBarDelegate = self
        enroll.tabBarDelegate = self
        challenge.tabBarDelegate = self
        
        enroll.homeViewDelegate = home
        
        let homeNaviVC = UINavigationController(rootViewController: home)
        let enrollNaviVC = UINavigationController(rootViewController: enroll)
        let challengeNaviVC = UINavigationController(rootViewController: challenge)
        
        viewControllers.append(contentsOf: [
            homeNaviVC,
            enrollNaviVC,
            challengeNaviVC
        ])
    }
    
    private func setupLayout() {
        [
            tabBarView,
            bottomInsetView,
            blurEffectView
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
            bottomInsetView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        blurEffectView.isHidden = true
        
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
                button.heightAnchor.constraint(equalToConstant: CGFloat.tabBarHeight),
                button.centerYAnchor.constraint(equalTo: tabBarView.centerYAnchor)
            ])
            
            if index == 2 {
                showUpdatedPoint(with: button)
            }
        }
    }
    
    private func showUpdatedPoint(with button: UIButton) {
        let redDotView = UIView()
        
        redDotView.backgroundColor = .red
        
        let redDotSize: CGFloat = 9
        redDotView.layer.cornerRadius = 4.5
        redDotView.clipsToBounds = true
        
        guard let imageView = button.imageView else { return }
        redDotView.translatesAutoresizingMaskIntoConstraints = false

        imageView.addSubview(redDotView)
        
        NSLayoutConstraint.activate([
            redDotView.heightAnchor.constraint(equalToConstant: redDotSize),
            redDotView.widthAnchor.constraint(equalToConstant: redDotSize),
            redDotView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 3),
            redDotView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -3)
        ])
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
        
        previousVC.clearNavigationStackExceptRoot()
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
        afterTappedButton(sender)
        
        if sender.tag == selectedIndex {
            if timer == nil {
                startTimer(with: sender.tag)
                selectedIndex = sender.tag
            }
        } else {
            timerExpired()
            selectedIndex = sender.tag
        }
    }
    
    private func startTimer(with tag: Int) {
        var timerInterval: TimeInterval = 1.5
        
        if tag == 2 {
            timerInterval = 8
        }

        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: false,
            block: { [weak self] _ in
            self?.timerExpired()
        })
    }
    
    private func timerExpired() {
        timer?.invalidate()
        timer = nil
    }
    
    private func afterTappedButton(_ button: UIButton) {
        vibrate()
        animateButton(button)
    }
    
    private func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        generator.impactOccurred()
    }
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.allowUserInteraction],
            animations: {
            button.transform = CGAffineTransform(scaleX: 1.08, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
    
    func activeBlurEffectView(with active: Bool) {
        blurEffectView.isHidden = !active
    }
}
