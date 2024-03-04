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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 48))
        
        view.backgroundColor = .gray6
        
        let countLabel = UILabel()
        countLabel.numberOfLines = 1
        countLabel.font = .pretendard(size: 18, weight: .semibold)
        countLabel.text = "총 \(6)개의 가게"
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 48

        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
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
