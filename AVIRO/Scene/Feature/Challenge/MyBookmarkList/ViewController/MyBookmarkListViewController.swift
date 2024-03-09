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
    weak var tabBarDelegate: TabBarDelegate?
    
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
        
        return view
    }()
    
    private lazy var noPlaceSubLabel: UILabel = {
        let lbl = UILabel()
        
        return lbl
    }()
    
    // TODO: 지금 후기 등록하기 배경 및 이미지 거꾸로 버전
    private lazy var enrollButton: UIButton = {
        let btn = UIButton()
        
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
            bookmarkTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            bookmarkTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bookmarkTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bookmarkTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bookmarkTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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
            .drive()
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
            .drive(self.rx.setFirstViewState)
            .disposed(by: disposeBag)
        
        output.bookmarkUpdateComplete
            .drive()
            .disposed(by: disposeBag)
        
        output.selectedBookmark
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.tabBarDelegate?.selectedIndex = 0
                }
            })
            .disposed(by: disposeBag)
        
        output.deletedBookmarks
            .drive()
            .disposed(by: disposeBag)
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
}

extension Reactive where Base: MyBookmarkListViewController {
    var setFirstViewState: Binder<Int> {
        return Binder(self.base) { base, result in
            base.bindingTableHeaderView(with: result)
        }
    }
    
    var whenDidScrollTableView: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.adjustHeaderInset()
        }
    }
}
