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
        let viewWillAppearTrigger = self.rx.viewWillAppear.map { _ in }.asDriver(onErrorDriveWith: .empty())
        
        let tappedNavigationBarRightButton = navigationItem.rightBarButtonItem?.rx.tap.asDriver() ?? .empty()
        
        let input = ChallengeViewModel.Input(
            loadData: viewWillAppearTrigger,
            tappedChallengeInfoButton: challengeTitleView.challengeInfoButtonTap,
            tappedNavigationBarRightButton: tappedNavigationBarRightButton
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
        
        output.error
            .drive(self.rx.isError)
            .disposed(by: disposeBag)
        
    }
    
    func bindChallengeInfo(with result: AVIROChallengeInfoDTO) {
        let period = result.period
        let title = result.title
        viewModel.challengeTitle = title

        challengeTitleView.updateDate(with: period)
        challengeTitleView.updateTitle(with: title)
    }
    
    func bindMyChallengeLevel(with result: AVIROMyChallengeLevelResultDTO) {
        challengeUserInfoView.bindData(with: result)
    }
    
    func bindMyContributionCount(with result: AVIROMyContributionCountDTO) {
        let placeCount = String(result.data?.placeCount ?? 0)
        let reviewCount = String(result.data?.commentCount ?? 0)
        let starCount = String(result.data?.bookmarkCount ?? 0)
        
        myInfoView.updateMyPlace(placeCount)
        myInfoView.updateMyReview(reviewCount)
        myInfoView.updateMyStar(starCount)
    }
    
    func pushChallengeInfoViewController() {
        let vc = ChallengeInfoViewController.create(with: viewModel.challengeTitle)
        
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
    
    func showErrorAlert() {
        self.showAlert(title: "에러", message: "재시도 해주세요")
    }
}

extension Reactive where Base: ChallengeViewController {
    var isMyContributionCountResult: Binder<AVIROMyContributionCountDTO> {
        return Binder(self.base) { base, result in
            base.bindMyContributionCount(with: result)
        }
    }
    
    var isChallengeInfoResult: Binder<AVIROChallengeInfoDTO> {
        return Binder(self.base) { base, result in
            base.bindChallengeInfo(with: result)
        }
    }
    
    var isMyChallengeLevelResult: Binder<AVIROMyChallengeLevelResultDTO> {
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
