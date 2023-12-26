//
//  ChallengeViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

import RxSwift
import RxCocoa

final class ChallengeViewController: UIViewController, AVIROViewController {
    weak var tabBarDelegate: TabBarDelegate?
    
    private var viewModel: ChallengeViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var challengeTitleView: ChallengeTitleView = {
        let view = ChallengeTitleView()
        
        return view
    }()
    
    private lazy var challengeUserInfoView: ChallengeUserInfoView = {
        let view = ChallengeUserInfoView()
        
        return view
    }()
    
    private lazy var myInfoView: MyInfoView = {
        let view = MyInfoView()
        
        return view
    }()
        
    static func create(with viewModel: ChallengeViewModel) -> ChallengeViewController {
        let vc = ChallengeViewController()
        vc.viewModel = viewModel
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
        dataBinding()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
        
        [
            challengeTitleView,
            challengeUserInfoView,
            myInfoView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            challengeTitleView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 16
            ),
            challengeTitleView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            challengeTitleView.heightAnchor.constraint(
                equalToConstant: 107
            ),
            
            challengeUserInfoView.topAnchor.constraint(
                equalTo: challengeTitleView.bottomAnchor,
                constant: 16
            ),
            challengeUserInfoView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            challengeUserInfoView.heightAnchor.constraint(
                equalToConstant: 341
            ),
            
            myInfoView.topAnchor.constraint(
                equalTo: challengeUserInfoView.bottomAnchor,
                constant: 20
            ),
            myInfoView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            myInfoView.heightAnchor.constraint(equalToConstant: 81),
            myInfoView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -32
            )
        ])
    }
    
    private func setupAttribute() {
        navigationItem.title = "챌린지"
        navigationController?.navigationBar.isHidden = false
        
        let rightBarButton = UIBarButtonItem(
            image: UIImage.user2,
            style: .done,
            target: nil,
            action: nil
        )
        rightBarButton.tintColor = .gray1

        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func dataBinding() {
        // TODO: ViewModel 생성 후 변경 예정
        challengeTitleView.updateDate(with: "1월 1일 ~ 1월 31일")
        challengeTitleView.updateTitle(with: "2024 비거뉴어리")
        
        myInfoView.updateMyPlace("2")
        myInfoView.updateMyReview("3")
        myInfoView.updateMyStar("4")
        
        let tappedNavigationBarRightButton = navigationItem.rightBarButtonItem?.rx.tap.asDriver() ?? .empty()
        
        let input = ChallengeViewModel.Input(
            tappedChallengeInfoButton: challengeTitleView.challengeInfoButtonTap,
            tappedNavigationBarRightButton: tappedNavigationBarRightButton
        )
        
        let output = viewModel.transform(with: input)
        
        output.afterTappedChallengeInfoButton
            .drive(self.rx.isPushChallengeInfoViewController)
            .disposed(by: disposeBag)
        
        output.afterTappedNavigationBarRightButton
            .drive(self.rx.isPushSettingViewController)
            .disposed(by: disposeBag)
    }
    
    func pushChallengeInfoViewController() {
        let vc = ChallengeInfoViewController.create(with: "2024 비거뉴어리")
        
        let presentationDelegate = ChallengeInfoPresentaionDelegate()
        
        vc.transitioningDelegate = presentationDelegate
        vc.modalPresentationStyle = .custom
        
        self.present(vc, animated: true)
    }
    
    // TODO: 수정 예정
    func pushSettingViewController() {
        let vc = SettingViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension Reactive where Base: ChallengeViewController {
    var isPushChallengeInfoViewController: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.pushChallengeInfoViewController()
        }
    }
    
    var isPushSettingViewController: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.pushSettingViewController()
        }
    }
}
