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
    weak var tabBarDelegate: TabBarDelegate?
    
    private var viewModel: MyCommentListViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var commentTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.rowHeight = UITableView.automaticDimension
        view.delegate = self
        view.dataSource = self
        view.register(
            MyCommentListTableViewCell.self,
            forCellReuseIdentifier: MyCommentListTableViewCell.identifier
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

    static func create(with viewModel: MyCommentListViewModel) -> MyCommentListViewController {
        let vc = MyCommentListViewController()
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
            commentTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            commentTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            commentTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            commentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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
    }
}

extension MyCommentListViewController: UITableViewDataSource {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyCommentListTableViewCell.identifier, for: indexPath) as? MyCommentListTableViewCell else {
            return UITableViewCell()
        }
        
        let model = MyCommentCellModel(
            commentId: "test",
            title: "하하하",
            category: "test",
            allVegan: false,
            someVegan: false,
            ifRequestVegan: false,
            date: "1일 전",
            content: "ㅋㅍㅋㄴㅍawfawf안니왜 왜awdawkfawlkf;lakwf;lkaw;lf왜왜왜왜ㅗ애ㅗ애ㅗ애ㅙㄴ"
        )
        
        cell.configuration(with: model)
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension MyCommentListViewController: UITableViewDelegate {

}
