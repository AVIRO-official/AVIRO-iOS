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
    
    private lazy var bookmarkTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.sectionHeaderTopPadding = 0
        view.register(
            MyBookmarkListTableViewCell.self,
            forCellReuseIdentifier: MyBookmarkListTableViewCell.identifier
        )
        
        return view
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
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
        dataBinding()
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
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.whenDidScrollTableView)
            .disposed(by: disposeBag)
    }
    
    private func dataBinding() {
        let viewWillAppearTrigger = self.rx.viewWillAppear
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let input = MyBookmarkListViewModel.Input(
            whenViewWillAppear: viewWillAppearTrigger
        )
        
        let output = viewModel.transform(with: input)
        
        output.myBookmarkList
            .drive(self.rx.isMyBookmarkList)
            .disposed(by: disposeBag)
        
        output.numberOfBookmarks
            .drive(self.rx.bookmarkListCount)
            .disposed(by: disposeBag)
    }
    
    internal func bindMyBookmarkList(with models: [MyBookmarkCellModel]) {
        Driver.just(models)
             .drive(bookmarkTableView.rx.items(
                 cellIdentifier: MyBookmarkListTableViewCell.identifier,
                 cellType: MyBookmarkListTableViewCell.self)
             ) { (row, model, cell) in
                 cell.configuration(with: model)
                 
                 cell.selectionStyle = .none
             }
             .disposed(by: disposeBag)
    }
    
    internal func bindTableHeaderView(with count: Int) {
        Driver.just(self.makeHeaderView(with: count))
              .drive(onNext: { [weak self] headerView in
                  self?.bookmarkTableView.tableHeaderView = headerView
              })
              .disposed(by: disposeBag)
    }
    
    private func makeHeaderView(with count: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 48))

        view.backgroundColor = .clear
        
        let countLabel = UILabel()
        countLabel.numberOfLines = 1
        countLabel.font = .pretendard(size: 18, weight: .semibold)
        countLabel.text = "총 \(count)개의 가게"
        countLabel.textColor = .gray0
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            countLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        return view
    }
    
    internal func adjustHeaderInset() {
        let sectionHeaderHeight: CGFloat = 48

        if bookmarkTableView.contentOffset.y <= sectionHeaderHeight && bookmarkTableView.contentOffset.y >= 0 {
            bookmarkTableView.contentInset = UIEdgeInsets(
                top: -bookmarkTableView.contentOffset.y,
                left: 0,
                bottom: 0,
                right: 0
            )
        } else if bookmarkTableView.contentOffset.y >= sectionHeaderHeight {
            bookmarkTableView.contentInset = UIEdgeInsets(
                top: -sectionHeaderHeight,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
}

extension MyBookmarkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        142
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        48
    }
}

extension Reactive where Base: MyBookmarkListViewController {
    var isMyBookmarkList: Binder<[MyBookmarkCellModel]> {
        return Binder(self.base) { base, result in
            base.bindMyBookmarkList(with: result)
        }
    }
    
    var bookmarkListCount: Binder<Int> {
        return Binder(self.base) { base, result in
            base.bindTableHeaderView(with: result)
        }
    }
    
    var whenDidScrollTableView: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.adjustHeaderInset()
        }
    }
}
