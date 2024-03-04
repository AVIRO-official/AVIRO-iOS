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
        view.dataSource = self
        view.delegate = self
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
    }
}

extension MyBookmarkListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        6
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyBookmarkListTableViewCell.identifier,
            for: indexPath
        ) as? MyBookmarkListTableViewCell else {
            return UITableViewCell()
        }
        
        let model = MyBookmarkCellModel(
            category: .Bar, all: true, some: false, request: false, title: "테스트", address: "테스트주소입니다", menu: "테스트메뉴테스트메뉴테스트메뉴테스트메뉴테스트메뉴", menuCount: "3", time: "5일 전", isStar: true
        )
        
        cell.configuration(with: model)
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension MyBookmarkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        142
    }
}
