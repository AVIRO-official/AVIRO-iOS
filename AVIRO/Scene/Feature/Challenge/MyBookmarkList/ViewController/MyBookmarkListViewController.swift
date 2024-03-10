//
//  MyBookmarkListViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import UIKit

import RxSwift
import RxCocoa

final class MyBookmarkListViewController: UIViewController {
    weak var tabBarDelegate: TabBarSettingDelegate?
    
    private var viewModel: MyBookmarkListViewModel!
    private let disposeBag = DisposeBag()
    
    private let starButtonTapped = PublishSubject<Int>()
    private let selectedBookmark = PublishSubject<Int>()
    
    private lazy var bookmarkTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.sectionHeaderTopPadding = 0
        view.register(
            MyBookmarkListTableViewCell.self,
            forCellReuseIdentifier: MyBookmarkListTableViewCell.identifier
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
        
        return view
    }()
    
    private lazy var noPlaceSubLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "아직 즐겨찾기한 가게가 없습니다\n지금 가게를 둘러볼까요?"
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    private lazy var noPlaceButton: NoListButton = {
        let btn = NoListButton()
        
        btn.setButton("홈으로 이동하기", .btn_home)
        
        return btn
    }()

    static func create(with viewModel: MyBookmarkListViewModel) -> MyBookmarkListViewController {
        let vc = MyBookmarkListViewController()
        
        vc.viewModel = viewModel
        vc.dataBinding()
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarDelegate?.isHidden = (false, true)
    }
    
    private func setupLayout() {
        [
            bookmarkTableView,
            berryImage,
            noPlaceSubLabel,
            noPlaceButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            bookmarkTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bookmarkTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bookmarkTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bookmarkTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            berryImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            berryImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40),
            
            noPlaceSubLabel.topAnchor.constraint(equalTo: berryImage.bottomAnchor, constant: 20),
            noPlaceSubLabel.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            
            noPlaceButton.topAnchor.constraint(equalTo: noPlaceSubLabel.bottomAnchor, constant: 20),
            noPlaceButton.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor)
        ])
    }
    
    private func setupAttribute() {
        navigationItem.title = "내가 등록한 가게"
        navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = .gray7

        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        
        setupBack(true)
        
        bookmarkTableView.rx.didScroll
            .debounce(.milliseconds(20), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.whenDidScrollTableView)
            .disposed(by: disposeBag)
        
        noPlaceButton.rx.tap
            .asDriver()
            .drive(self.rx.whenDidTappedNoPlaceButton)
            .disposed(by: disposeBag)
    }
    
    private func dataBinding() {
        let viewDidLoadTrigger = self.rx.viewDidLoad
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let viewWillDisAppearTrigger = self.rx.viewWillDisAppear
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let input = MyBookmarkListViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger,
            viewWillDisAppearTrigger: viewWillDisAppearTrigger,
            bookmarkStateChangeIndex: starButtonTapped.asDriver(onErrorJustReturn: 0),
            selectedBookmarkIndex: selectedBookmark.asDriver(onErrorJustReturn: 0)
        )
        
        let output = viewModel.transform(with: input)
        
        output.hasBookmarks
            .drive(self.rx.hasBookmarks)
            .disposed(by: disposeBag)
        
        output.bookmarksData
            .drive(
                bookmarkTableView.rx.items(
                    cellIdentifier: MyBookmarkListTableViewCell.identifier,
                    cellType: MyBookmarkListTableViewCell.self)
            ) { (row, model, cell) in
                cell.configuration(with: model)
                
                cell.onStarButtonTapped = { [weak self] in
                    self?.starButtonTapped.onNext(row)
                }
                
                cell.onTouchRelease = { [weak self] in
                    self?.selectedBookmark.onNext(row)
                }
                
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.bookmarkLoadError
            .drive()
            .disposed(by: disposeBag)
        
        output.countOfStarredBookmarks
            .drive(self.rx.setTableHeaderView)
            .disposed(by: disposeBag)
        
        output.bookmarkUpdateComplete
            .drive()
            .disposed(by: disposeBag)
        
        output.selectedBookmark
            .drive(onNext: { [weak self] placeId in
                guard let self = self else { return }
                // 시간차 이동을 위한 async After
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.tabBarDelegate?.setSelectedIndex(
                        0,
                        withKey: TabBarKeys.placeId,
                        value: placeId
                    )
                }
            })
            .disposed(by: disposeBag)
        
        output.deletedBookmarks
            .drive()
            .disposed(by: disposeBag)
    }
    
    internal func bindingWhenViewDidLoad(with isHiddenTableView: Bool) {
        bookmarkTableView.isHidden = !isHiddenTableView
        
        berryImage.isHidden = isHiddenTableView
        noPlaceSubLabel.isHidden = isHiddenTableView
        noPlaceButton.isHidden = isHiddenTableView
    }
    
    internal func bindingTableHeaderView(with count: Int) {
        guard bookmarkTableView.tableHeaderView != nil else {
            Driver.just(self.makeTableHeaderView(with: count))
                .drive(onNext: { [weak self] headerView in
                    self?.bookmarkTableView.tableHeaderView = headerView
                })
                .disposed(by: disposeBag)
            
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
        
        let bookmarkYOffset = bookmarkTableView.contentOffset.y

        if bookmarkYOffset <= sectionHeaderHeight && bookmarkYOffset == 0 {
            bookmarkTableView.contentInset = UIEdgeInsets(
                top: -bookmarkTableView.contentOffset.y,
                left: 0,
                bottom: 0,
                right: 0
            )
        } else if bookmarkTableView.contentOffset.y >= sectionHeaderHeight {
            bookmarkTableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
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
}

extension Reactive where Base: MyBookmarkListViewController {
    var hasBookmarks: Binder<Bool> {
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
    
    var whenDidTappedNoPlaceButton: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.noPlaceButtonTapped()
        }
    }
}
