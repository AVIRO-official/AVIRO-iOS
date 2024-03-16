//
//  AVIROTabBarController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import UIKit

final class AVIROTabBarController: UIViewController, TabBarFromSubVCDelegate {
    
    private lazy var viewControllers: [UINavigationController] = []
    private var wellcomeViewController: WellcomeViewController?
    
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
    
    private lazy var tabBarBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        view.effect = blurEffect
        view.alpha = 0.3
        view.isHidden = true
        
        return view
    }()
    
    private lazy var wellcomeView: UIView = {
        let view = UIView()
       
        view.backgroundColor = .clear
        view.isHidden = true
        
        wellcomeViewController = WellcomeViewController.create()
        
        if let wellcomeVC = wellcomeViewController {
            add(child: wellcomeVC, container: view)
            view.addSubview(wellcomeVC.view)
        }
        
        return view
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        view.effect = blurEffect
        view.alpha = 0.3
        view.isHidden = true
        
        return view
    }()
    
    var afterFetchingData: Bool = false
            
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    func setViewControllers(with types: [TabBarType]) {
        
        self.types = types
        let home = HomeViewController()
        
        let enroll = EnrollPlaceViewController()
    
        let bookmarkManager = BookmarkFacadeManager()
        let challengeViewModel = ChallengeViewModel(bookmarkManager: bookmarkManager)
        
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
    
    // MARK: - TabBat Setup
    private func setupLayout() {
        [
            tabBarView,
            bottomInsetView,
            tabBarBlurView,
            blurView,
            wellcomeView
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
            
            tabBarBlurView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            tabBarBlurView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            tabBarBlurView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            tabBarBlurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            wellcomeView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            wellcomeView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            wellcomeView.widthAnchor.constraint(equalToConstant: 280),
            wellcomeView.heightAnchor.constraint(equalToConstant: 415)
        ])
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .clear
        
        setupButtons()
        checkWellcomeShow()
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
    // MARK: - Wellcome VC
    private func checkWellcomeShow() {
        guard let compareDate = UserDefaults.standard.object(
            forKey: UDKey.hideUntil.rawValue
        ) as? Date else {
            showWellcomeVC()
            return
        }
        
        let components = Calendar.current.dateComponents(
            [.hour],
            from: compareDate,
            to: Date()
        )
        
        if let hoursPassed = components.hour, hoursPassed >= 24 {
            showWellcomeVC()
        }
    }
    
    private func showWellcomeVC() {
        wellcomeViewController?.tabBarDelegate = self
        wellcomeViewController?.dataBinding { [weak self] in
            self?.wellcomeViewController?.didNoShowButtonTapped = {
                UserDefaults.standard.set(Date(), forKey: UDKey.hideUntil.rawValue)
                
                self?.removeWellcomVC()
            }
            
            self?.wellcomeViewController?.didCloseButtonTapped = {
                self?.removeWellcomVC()
            }
            
            self?.wellcomeViewController?.didCheckButtonTapped = {
                self?.selectedIndex = 2
                self?.removeWellcomVC()
            }
            
            self?.blurView.isHidden = false
            self?.wellcomeView.isHidden = false
        }
    }
    
    private func removeWellcomVC() {
        blurView.isHidden = true
        wellcomeView.isHidden = true

        wellcomeViewController?.remove()
    }
    
    // MARK: - TabBar Click After
    private func updateView() {
        deleteView()
        setupView()
        
        buttons.forEach {
            $0.isSelected = ($0.tag == selectedIndex)
        }
    }
    
    private func deleteView() {
        let previousVC = viewControllers[previousIndex]
        
        /// remove -> clearNavigationStackExceptRoot 순으로 진행해야
        /// child view들의 lifeCycle 함수들이 정상적으로 호출됨
        previousVC.remove()
        previousVC.clearNavigationStackExceptRoot()

    }

    // TODO: - Refectoring 필요
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
        checkAfterFetching(with: sender)
    }
    
    private func checkAfterFetching(with sender: TabBarButton) {
        if afterFetchingData {
            afterTappedButton(sender)
            whenSelectedIndex(with: sender.tag)
        } else {
            showSimpleToast(
                with: "데이터 동기화 중 입니다!",
                position: .top
            )
        }
    }
    
    private func whenSelectedIndex(with index: Int) {
        guard index != selectedIndex else { return }
        
        selectedIndex = index
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
    
    // MARK: - Selecetd Index With Key
    func setSelectedIndex(
        _ index: Int,
        withData data: [String: Any]
    ) {
        self.selectedIndex = index
        
        weak var delegate = viewControllers[index].topViewController as? TabBarToSubVCDelegate
        
        delegate?.handleTabBarInteraction(withData: data)
    }
    
    func activeBlurEffectView(with active: Bool) {
        tabBarBlurView.isHidden = !active
    }
}
