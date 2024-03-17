//
//  ChallengeViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

import RxSwift
import RxCocoa

enum MyInfoType {
    case place
    case review
    case bookmark
}

final class ChallengeViewController: UIViewController {
    weak var tabBarDelegate: TabBarFromSubVCDelegate?
    
    private var viewModel: ChallengeViewModel!
    private let disposeBag = DisposeBag()
    
    private let rightNaivagtionBarTapped = PublishSubject<Void>()
    private let userInfoListTapped = PublishSubject<MyInfoType>()
    
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
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.tintColor = .gray3
        
        return refreshControl
    }()
        
    static func create(with viewModel: ChallengeViewModel) -> ChallengeViewController {
        let vc = ChallengeViewController()
        
        vc.viewModel = viewModel
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
        
        dataBinding()
    }

    private func setupLayout() {
        [
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

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
            challengeTitleView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            challengeTitleView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            challengeTitleView.heightAnchor.constraint(
                equalToConstant: 107
            ),
            
            challengeUserInfoView.topAnchor.constraint(
                equalTo: challengeTitleView.bottomAnchor,
                constant: 16
            ),
            challengeUserInfoView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            challengeUserInfoView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            challengeUserInfoView.heightAnchor.constraint(
                equalToConstant: 341
            ),
            
            myInfoView.topAnchor.constraint(
                equalTo: challengeUserInfoView.bottomAnchor,
                constant: 20
            ),
            myInfoView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            myInfoView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
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
        
        self.view.backgroundColor = .gray7
        
        let rightBarButton = UIBarButtonItem(
            image: UIImage.user2,
            style: .done,
            target: nil,
            action: nil
        )
        rightBarButton.tintColor = .gray1
        rightBarButton.rx.tap
            .bind(to: rightNaivagtionBarTapped)
            .disposed(by: disposeBag)
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        scrollView.refreshControl = refreshControl
        
        myInfoView.tappedMyInfo = { [weak self] myInfoType in
            self?.userInfoListTapped.onNext(myInfoType)
        }
    }
    
    private func dataBinding() {
        let viewWillAppearTrigger = self.rx.viewWillAppear
            .do { [weak self] _ in
                self?.challengeUserInfoView.startIndicator()
            }
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())

        let refeshControlEvent = refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
        
        let onRightNavigationBarButtonTapped = rightNaivagtionBarTapped
            .asDriver(onErrorDriveWith: .empty())
        
        let onUserInfoListTapped = userInfoListTapped
            .do { [weak self] myInfoType in
                guard let self = self else { return }
                
                self.pushMyInfo(with: myInfoType)
                
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let input = ChallengeViewModel.Input(
            whenViewWillAppear: viewWillAppearTrigger,
            whenRefesh: refeshControlEvent,
            onChallengeInfoButtonTapped: challengeTitleView.challengeInfoButtonTap,
            onRightNavigationBarButtonTapped: onRightNavigationBarButtonTapped,
            onUserInfoListTapped: onUserInfoListTapped
        )
        
        let output = viewModel.transform(with: input)
        
        output.myContributionCountResult
            .drive(self.rx.isMyContributionCountResult)
            .disposed(by: disposeBag)
        
        output.challengeInfoResult
            .drive(self.rx.isChallengeInfoResult)
            .disposed(by: disposeBag)
        
        output.myChallengeLevelResult
            .drive(self.rx.isMyChallengeLevelResult)
            .disposed(by: disposeBag)
        
        output.afterTappedChallengeInfoButton
            .drive(self.rx.isPushChallengeInfoViewController)
            .disposed(by: disposeBag)
        
        output.afterTappedNavigationBarRightButton
            .drive(self.rx.isPushSettingViewController)
            .disposed(by: disposeBag)
        
        output.afterUserInfoListTapped
            .drive()
            .disposed(by: disposeBag)
        
        output.error
            .drive(self.rx.isError)
            .disposed(by: disposeBag)
    }
    
    internal func bindChallengeInfo(with result: AVIROChallengeInfoDataDTO) {
        let period = result.period
        let title = result.title
        viewModel.challengeTitle = title

        challengeTitleView.updateDate(with: period)
        challengeTitleView.updateTitle(with: title)
        
        endRefeshControl()
    }
    
    internal func bindMyChallengeLevel(with result: AVIROMyChallengeLevelDataDTO) {
        challengeUserInfoView.endIndicator()
        challengeUserInfoView.bindData(with: result)
        
        endRefeshControl()
    }
    
    internal func bindMyContributionCount(with result: AVIROMyActivityCounts) {
        let placeCount = String(result.placeCount)
        let reviewCount = String(result.commentCount)
        let starCount = String(result.bookmarkCount)
                
        myInfoView.updateMyPlace(placeCount)
        myInfoView.updateMyReview(reviewCount)
        myInfoView.updateMyStar(starCount)
        
        endRefeshControl()
    }
    
    private func endRefeshControl() {
        scrollView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Navigation Method

    func pushChallengeInfoViewController() {
        let vc = ChallengeInfoViewController.create(with: viewModel.challengeTitle)
        
        let presentationDelegate = ChallengeInfoPresentaionDelegate()
        
        vc.transitioningDelegate = presentationDelegate
        vc.modalPresentationStyle = .custom
        
        self.present(vc, animated: true)
    }
    
    func pushSettingViewController() {
        let vc = SettingViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showErrorAlert() {
        self.showAlert(title: "에러", message: "재시도 해주세요")
        
        endRefeshControl()
    }
    
    private func pushMyInfo(with myInfoType: MyInfoType) {
        self.tabBarDelegate?.isHidden = (true, true)

        switch myInfoType {
        case .place:
            let viewModel = MyPlaceListViewModel()
            let vc = MyPlaceListViewController.create(with: viewModel)
            vc.tabBarDelegate = self.tabBarDelegate
            
            navigationController?.pushViewController(vc, animated: true)
        case .review:
            let viewModel = MyCommentListViewModel()
            let vc = MyCommentListViewController.create(with: viewModel)
            vc.tabBarDelegate = self.tabBarDelegate

            navigationController?.pushViewController(vc, animated: true)
        case .bookmark:
            let viewModel = MyBookmarkListViewModel(
                challengeViewModelProtocol: self.viewModel,
                bookmarkManager: BookmarkFacadeManager()
            )
            let vc = MyBookmarkListViewController.create(with: viewModel)
            vc.tabBarDelegate = self.tabBarDelegate

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Reactive where Base: ChallengeViewController {
    var isMyContributionCountResult: Binder<AVIROMyActivityCounts> {
        return Binder(self.base) { base, result in
            base.bindMyContributionCount(with: result)
        }
    }
    
    var isChallengeInfoResult: Binder<AVIROChallengeInfoDataDTO> {
        return Binder(self.base) { base, result in
            base.bindChallengeInfo(with: result)
        }
    }
    
    var isMyChallengeLevelResult: Binder<AVIROMyChallengeLevelDataDTO> {
        return Binder(self.base) { base, result in
            base.bindMyChallengeLevel(with: result)
        }
    }
    
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
    
    var isError: Binder<APIError> {
        return Binder(self.base) { base, _ in
            base.showErrorAlert()
        }
    }
}
