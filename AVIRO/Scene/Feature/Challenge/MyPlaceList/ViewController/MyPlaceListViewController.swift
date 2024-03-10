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
    weak var tabBarDelegate: TabBarSettingDelegate?

    private var viewModel: MyPlaceListViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var placeTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.sectionHeaderTopPadding = 0
        view.register(
            MyPlaceListTableViewCell.self,
            forCellReuseIdentifier: MyPlaceListTableViewCell.identifier
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
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        
        view.style = .large
        view.color = .gray5
        view.startAnimating()
        view.isHidden = true
        
        return view
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        view.effect = blurEffect
        view.alpha = 0.6
        view.isHidden = true
        
        return view
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
        dataBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarDelegate?.isHidden = (false, true)
    }
    
    private func setupLayout() {
        [
            placeTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
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
        
        /// didScroll이 매우 빠른 연속 이벤트임으로 debounce를 활용해 이벤트 스트림을 안정화 시킴
        placeTableView.rx.didScroll
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.whenDidScrollTableView)
            .disposed(by: disposeBag)
    }
    
    private func dataBinding() {
        let viewWillAppearTrigger = self.rx.viewWillAppear
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let input = MyPlaceListViewModel.Input(
            whenViewWillAppear: viewWillAppearTrigger
        )
        
        let output = viewModel.transform(with: input)
        
        output.myPlaceList
            .drive(self.rx.isMyPlaceListResult)
            .disposed(by: disposeBag)
        
        output.numberOfPlaces
            .drive(self.rx.placeListCount)
            .disposed(by: disposeBag)
        
    }
    
    internal func bindMyPlaceList(with models: [MyPlaceCellModel]) {
        Driver.just(models)
             .drive(placeTableView.rx.items(
                 cellIdentifier: MyPlaceListTableViewCell.identifier,
                 cellType: MyPlaceListTableViewCell.self)
             ) { (row, model, cell) in
                 cell.configuration(with: model)
                 
                 cell.selectionStyle = .none
             }
             .disposed(by: disposeBag)
    }
    
    internal func bindTableHeaderView(with count: Int) {
        Driver.just(self.makeHeaderView(with: count))
              .drive(onNext: { [weak self] headerView in
                  self?.placeTableView.tableHeaderView = headerView
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

        if placeTableView.contentOffset.y <= sectionHeaderHeight && placeTableView.contentOffset.y >= 0 {
            placeTableView.contentInset = UIEdgeInsets(
                top: -placeTableView.contentOffset.y,
                left: 0,
                bottom: 0,
                right: 0
            )
        } else if placeTableView.contentOffset.y >= sectionHeaderHeight {
            placeTableView.contentInset = UIEdgeInsets(
                top: -sectionHeaderHeight,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
}

extension MyPlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        142
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        48
    }
}

extension Reactive where Base: MyPlaceListViewController {
    var isMyPlaceListResult: Binder<[MyPlaceCellModel]> {
        return Binder(self.base) { base, result in
            base.bindMyPlaceList(with: result)
        }
    }
    
    var placeListCount: Binder<Int> {
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
