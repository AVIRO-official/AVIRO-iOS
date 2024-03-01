//
//  MyPlaceListViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/01.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPlaceListViewController: UIViewController {
    weak var tabBarDelegate: TabBarDelegate?

    private var viewModel: MyPlaceListViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var placeTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        
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
    
    static func create(with viewModel: MyPlaceListViewModel) -> MyPlaceListViewController {
        let vc = MyPlaceListViewController()
        vc.viewModel = viewModel
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    private func setupLayout() {
        [
            placeTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            placeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            placeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            placeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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
