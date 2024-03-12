//
//  MyCommentListViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import UIKit

import RxSwift
import RxCocoa

final class MyCommentListViewController: UIViewController {
    // MARK: - Property
    weak var tabBarDelegate: TabBarSettingDelegate?
    
    private var viewModel: MyCommentListViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - Stream Property
    private let selectedReview = PublishSubject<Int>()
    private let deletedReview = PublishSubject<Int>()
    
    // MARK: - UI Component
    private lazy var commentTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.isHidden = true
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        view.sectionHeaderTopPadding = 0
        view.register(
            MyCommentListTableViewCell.self,
            forCellReuseIdentifier: MyCommentListTableViewCell.identifier
        )
        
        return view
    }()
    
    private lazy var listCountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.numberOfLines = 1
        lbl.font = .pretendard(size: 18, weight: .semibold)
        lbl.textColor = .gray0
        
        return lbl
    }()
    
    private lazy var berryImage: UIImageView = {
        let view = UIImageView()
        
        view.image = .enrollCharacter
        view.isHidden = true
        
        return view
    }()
    
    private lazy var noPlaceSubLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "아직 작성한 후기가 없습니다\n \(MyData.my.nickname)님의 후기를 들려주실래요?"
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.isHidden = true
        
        return lbl
    }()
    
    private lazy var noPlaceButton: NoListButton = {
        let btn = NoListButton()
        
        btn.setButton("지금 후기 작성하기", .btn_pencil)
        btn.isHidden = true
        
        return btn
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        
        indicatorView.style = .medium
        indicatorView.color = .gray0
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        
        return indicatorView
    }()

    // MARK: - Create
    
    static func create(with viewModel: MyCommentListViewModel) -> MyCommentListViewController {
        let vc = MyCommentListViewController()
        
        vc.viewModel = viewModel
        vc.dataBinding()
        
        return vc
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarDelegate?.isHidden = (false, true)
    }
    
    // MARK: - Setup Method
    
    private func setupLayout() {
        [
            commentTableView,
            berryImage,
            noPlaceSubLabel,
            noPlaceButton,
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            commentTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            commentTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            commentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            berryImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            berryImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40),
            
            noPlaceSubLabel.topAnchor.constraint(equalTo: berryImage.bottomAnchor, constant: 20),
            noPlaceSubLabel.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            noPlaceSubLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            noPlaceSubLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            
            noPlaceButton.topAnchor.constraint(equalTo: noPlaceSubLabel.bottomAnchor, constant: 20),
            noPlaceButton.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            noPlaceButton.widthAnchor.constraint(equalToConstant: 172),
            noPlaceButton.heightAnchor.constraint(equalToConstant: 48),
            
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        navigationItem.title = "내가 작성한 후기"
        navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = .gray7

        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        
        setupBack(true)
        
        commentTableView.rx.didScroll
            .debounce(.milliseconds(20), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.whenDidScrollTableView)
            .disposed(by: disposeBag)
        
        noPlaceButton.rx.tap
            .asDriver()
            .drive(self.rx.whenDidTappedNoPlaceButton)
            .disposed(by: disposeBag)
    }
    
    // MARK: - DataBinding Method
    private func dataBinding() {
        let viewDidLoadTrigger = self.rx.viewDidLoad
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let selectedReviewIndex = selectedReview.asDriver(onErrorJustReturn: 0)
        let deletedReviewIndex = deletedReview.asDriver(onErrorJustReturn: 0)
        
        let input = MyCommentListViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger,
            selectedReviewIndex: selectedReviewIndex,
            deletedReviewIndex: deletedReviewIndex
        )
        
        let output = viewModel.transform(with: input)
        
        output.hasReviews
            .drive(self.rx.hasReviews)
            .disposed(by: disposeBag)
        
        output.reviewsData
            .drive(
                commentTableView.rx.items(
                    cellIdentifier: MyCommentListTableViewCell.identifier,
                    cellType: MyCommentListTableViewCell.self)
            ) { (row, model, cell) in
                cell.configuration(with: model)
                
                cell.onDotTapped = { [weak self] in
                    self?.showDeleteReviewAlert(with: row)
                }
                
                cell.onTouchRelease = { [weak self] in
                    self?.selectedReview.onNext(row)
                }
                
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.reviewsLoadError
            .drive()
            .disposed(by: disposeBag)
        
        output.numberOfReviews
            .drive(self.rx.setTableHeaderView)
            .disposed(by: disposeBag)
        
        output.selectedReview
            .drive(self.rx.whenDidTappedCell)
            .disposed(by: disposeBag)
        
        output.deletedReview
            .drive(self.rx.whenAfterDeletedReview)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Binding Setting Method
    internal func bindingWhenViewDidLoad(with isHiddenTableView: Bool) {
        indicatorView.isHidden = true

        commentTableView.isHidden = !isHiddenTableView
        
        berryImage.isHidden = isHiddenTableView
        noPlaceSubLabel.isHidden = isHiddenTableView
        noPlaceButton.isHidden = isHiddenTableView
    }
    
    internal func bindingTableHeaderView(with count: Int) {
        guard commentTableView.tableHeaderView != nil else {
            let headerView = makeTableHeaderView(with: count)
            
            commentTableView.tableHeaderView = headerView
            
            return
        }
        
        listCountLabel.text = "총 \(count)개의 가게"
    }
    
    private func makeTableHeaderView(with count: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 48))
        
        view.backgroundColor = .clear
        
        listCountLabel.text = "총 \(count)개의 가게"
        listCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(listCountLabel)
        
        NSLayoutConstraint.activate([
            listCountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            listCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            listCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        return view
    }
    
    internal func adjustHeaderInset() {
        let sectionHeaderHeight: CGFloat = 48
        
        let bookmarkYOffset = commentTableView.contentOffset.y

        if bookmarkYOffset <= sectionHeaderHeight && bookmarkYOffset == 0 {
            commentTableView.contentInset = UIEdgeInsets(
                top: -commentTableView.contentOffset.y,
                left: 0,
                bottom: 0,
                right: 0
            )
        } else if commentTableView.contentOffset.y >= sectionHeaderHeight {
            commentTableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
    
    internal func reviewCellDidTapped(with placeId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.tabBarDelegate?.setSelectedIndex(
                0,
                withData: [
                    TabBarKeys.placeId: placeId,
                    TabBarKeys.showReview: true
                ]
            )
        }
    }
    
    internal func reviewAfterDeletedAction(with result: String) {
        self.showSimpleToast(with: result)
    }
    
    internal func noPlaceButtonTapped() {
        noPlaceButton.animateTouchResponse(isTouchDown: true) { [weak self] in
            self?.noPlaceButton.animateTouchResponse(isTouchDown: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self?.tabBarDelegate?.selectedIndex = 0
                }
            }
        }
    }
    
    private func showDeleteReviewAlert(with index: Int) {
        let cancelAction = AlertAction(
            title: "취소",
            style: .cancel, nil
        )
        
        let deleteAction = AlertAction(
            title: "삭제하기",
            style: .destructive
        ) { [weak self] in
            self?.deletedReview.onNext(index)
        }
        
        self.showAlert(
            title: "정말로 선택한 후기를\n삭제하시겠어요?",
            message: "삭제하면 다시 복구할 수 없고 챌린지 포인트가 다시 회수돼요.",
            actions: [cancelAction, deleteAction]
        )
    }
}

extension Reactive where Base: MyCommentListViewController {
    var hasReviews: Binder<Bool> {
        return Binder(self.base) { base, result in
            base.bindingWhenViewDidLoad(with: result)
        }
    }
    
    var setTableHeaderView: Binder<Int> {
        return Binder(self.base) { base, result in
            base.bindingTableHeaderView(with: result)
        }
    }
    
    var whenDidScrollTableView: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.adjustHeaderInset()
        }
    }
    
    var whenDidTappedCell: Binder<String> {
        return Binder(self.base) { base, result in
            base.reviewCellDidTapped(with: result)
        }
    }
    
    var whenAfterDeletedReview: Binder<String> {
        return Binder(self.base) { base, result in
            base.reviewAfterDeletedAction(with: result)
        }
    }
    
    var whenDidTappedNoPlaceButton: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.noPlaceButtonTapped()
        }
    }
}
