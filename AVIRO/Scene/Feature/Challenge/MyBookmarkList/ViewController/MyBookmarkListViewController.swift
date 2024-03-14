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
    // MARK: - Property
    weak var tabBarDelegate: TabBarSettingDelegate?
    
    private var viewModel: MyBookmarkListViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - Stream Property
    private let starButtonTapped = PublishSubject<Int>()
    private let selectedBookmark = PublishSubject<Int>()
    
    // MARK: - UI Component
    private lazy var bookmarkTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.sectionHeaderTopPadding = 0
        view.isHidden = true
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
        view.isHidden = true
        
        return view
    }()
    
    private lazy var noPlaceSubLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "아직 즐겨찾기한 가게가 없습니다\n지금 가게를 둘러볼까요?"
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.isHidden = true
        
        return lbl
    }()
    
    private lazy var noPlaceButton: NoListButton = {
        let btn = NoListButton()
        
        btn.setButton("홈으로 이동하기", .btn_home)
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
    static func create(with viewModel: MyBookmarkListViewModel) -> MyBookmarkListViewController {
        let vc = MyBookmarkListViewController()
        
        vc.viewModel = viewModel
        vc.dataBinding()
        
        return vc
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
    }
    
    // MARK: - Setup Method
    private func setupLayout() {
        [
            bookmarkTableView,
            berryImage,
            noPlaceSubLabel,
            noPlaceButton,
            indicatorView
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
            noPlaceButton.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            noPlaceButton.widthAnchor.constraint(equalToConstant: 172),
            noPlaceButton.heightAnchor.constraint(equalToConstant: 48),
            
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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
    
    // MARK: - DataBinding Method
    private func dataBinding() {
        let viewDidLoadTrigger = self.rx.viewDidLoad
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let viewWillDisAppearTrigger = self.rx.viewWillDisAppear
            .do(onNext: { [weak self] _ in
                self?.tabBarDelegate?.isHidden = (false, true)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let bookmarkStateChangeIndex = starButtonTapped.asDriver(onErrorJustReturn: 0)
        let selectedBookmarkIndex = selectedBookmark.asDriver(onErrorJustReturn: 0)
        
        let input = MyBookmarkListViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger,
            viewWillDisAppearTrigger: viewWillDisAppearTrigger,
            bookmarkStateChangeIndex: bookmarkStateChangeIndex,
            selectedBookmarkIndex: selectedBookmarkIndex
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
        
        output.numberOfStarredBookmarks
            .drive(self.rx.setTableHeaderView)
            .disposed(by: disposeBag)
        
        output.updatedBookmarks
            .drive()
            .disposed(by: disposeBag)
        
        output.selectedBookmark
            .drive(self.rx.whenDidTappedCell)
            .disposed(by: disposeBag)
        
        output.deletedBookmarks
            .drive()
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Binding Setting Method
    internal func bindingWhenViewDidLoad(with isHiddenTableView: Bool) {
        indicatorView.isHidden = true
        
        bookmarkTableView.isHidden = !isHiddenTableView
        
        berryImage.isHidden = isHiddenTableView
        noPlaceSubLabel.isHidden = isHiddenTableView
        noPlaceButton.isHidden = isHiddenTableView
    }
    
    internal func bindingTableHeaderView(with count: Int) {
        guard bookmarkTableView.tableHeaderView != nil else {
            let headerView = makeTableHeaderView(with: count)
            
            bookmarkTableView.tableHeaderView = headerView
            
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
    
    internal func bookmarkCellDidTapped(with placeId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.tabBarDelegate?.setSelectedIndex(0, withData: [TabBarKeys.placeId: placeId])
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
    
    var whenDidTappedCell: Binder<String> {
        return Binder(self.base) { base, result in
            base.bookmarkCellDidTapped(with: result)
        }
    }
    
    var whenDidTappedNoPlaceButton: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.noPlaceButtonTapped()
        }
    }
}
