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
    // MARK: - Property
    weak var tabBarDelegate: TabBarFromSubVCDelegate?

    private var viewModel: MyPlaceListViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - Stream Property
    private let selectedPlace = PublishSubject<Int>()
    
    // MARK: - UI Component
    private lazy var placeTableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .gray6
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.isHidden = true
        view.sectionHeaderTopPadding = 0
        view.register(
            MyPlaceListTableViewCell.self,
            forCellReuseIdentifier: MyPlaceListTableViewCell.identifier
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
        
        lbl.text = "아직 등록한 가게가 없습니다\n지금 가게를 등록하러 가볼까요?"
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.isHidden = true
        
        return lbl
    }()
    
    private lazy var noPlaceButton: NoListButton = {
        let btn = NoListButton()
        
        btn.setButton("지금 가게 등록하기", .btn_plus_square)
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
    
    // MARK: - create
    static func create(with viewModel: MyPlaceListViewModel) -> MyPlaceListViewController {
        let vc = MyPlaceListViewController()
        
        vc.viewModel = viewModel
        vc.dataBinding()
        
        return vc
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarDelegate?.isHidden = (false, true)
    }
    
    // MARK: - Setup Method
    private func setupLayout() {
        [
            placeTableView,
            berryImage,
            noPlaceSubLabel,
            noPlaceButton,
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            placeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            placeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            placeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            berryImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            berryImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40),
            
            noPlaceSubLabel.topAnchor.constraint(equalTo: berryImage.bottomAnchor, constant: 20),
            noPlaceSubLabel.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            
            noPlaceButton.topAnchor.constraint(equalTo: noPlaceSubLabel.bottomAnchor, constant: 20),
            noPlaceButton.centerXAnchor.constraint(equalTo: berryImage.centerXAnchor),
            noPlaceButton.widthAnchor.constraint(equalToConstant: 188),
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
        
        placeTableView.rx.didScroll
            .debounce(.milliseconds(20), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.whenDidScrollTableView)
            .disposed(by: disposeBag)
        
        noPlaceButton.rx.tap
            .asDriver()
            .drive(self.rx.whenDidTappedNoPlaceButton)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Binding Method
    private func dataBinding() {
        let viewDidLoadTrigger = self.rx.viewDidLoad
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let selectedPlaceIndex = selectedPlace.asDriver(onErrorJustReturn: 0)
        
        let input = MyPlaceListViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger,
            selectedPlaceIndex: selectedPlaceIndex
        )
        
        let output = viewModel.transform(with: input)
        
        output.hasPlaces
            .drive(self.rx.hasPlaces)
            .disposed(by: disposeBag)
        
        output.placesData
            .drive(
                placeTableView.rx.items(
                    cellIdentifier: MyPlaceListTableViewCell.identifier,
                    cellType: MyPlaceListTableViewCell.self
                )
            ) { (row, model, cell) in
                
                cell.configuration(with: model)
                
                cell.onTouchRelease = { [weak self] in
                    self?.selectedPlace.onNext(row)
                }
                
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.placesLoadError
            .drive()
            .disposed(by: disposeBag)
        
        output.numberOfPlaces
            .drive(self.rx.setTableHeaderView)
            .disposed(by: disposeBag)
        
        output.selectedPlace
            .drive(self.rx.whenDidTappedCell)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Binding Setting Method
    internal func bindingWhenViewDidLoad(with isHiddenTableView: Bool) {
        indicatorView.isHidden = true
        
        placeTableView.isHidden = !isHiddenTableView
        
        berryImage.isHidden = isHiddenTableView
        noPlaceSubLabel.isHidden = isHiddenTableView
        noPlaceButton.isHidden = isHiddenTableView
    }
    
    internal func bindingTableHeaderView(with count: Int) {
        guard placeTableView.tableHeaderView != nil else {
            Driver.just(self.makeTableHeaderView(with: count))
                .drive(onNext: { [weak self] headerView in
                    self?.placeTableView.tableHeaderView = headerView
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

        let placeTableYOffset = placeTableView.contentOffset.y

        if placeTableYOffset <= sectionHeaderHeight && placeTableYOffset == 0 {
            placeTableView.contentInset = UIEdgeInsets(
                top: -placeTableView.contentOffset.y,
                left: 0,
                bottom: 0,
                right: 0
            )
        } else if placeTableView.contentOffset.y >= sectionHeaderHeight {
            placeTableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
    
    internal func placeCellDidTapped(with placeId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.tabBarDelegate?.setSelectedIndex(
                0,
                withData: [
                    TabBarKeys.placeId: placeId,
                    TabBarKeys.source : TabBarSourceValues.placeList
                ]
            )
        }

    }
    
    internal func noPlaceButtonTapped() {
        noPlaceButton.activeTouchActionEffect(isTouchDown: true) { [weak self] in
            self?.noPlaceButton.activeTouchActionEffect(isTouchDown: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self?.tabBarDelegate?.selectedIndex = 1
                }
            }
        }
    }
}

extension Reactive where Base: MyPlaceListViewController {
    var hasPlaces: Binder<Bool> {
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
            return base.placeCellDidTapped(with: result)
        }
    }
    
    var whenDidTappedNoPlaceButton: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.noPlaceButtonTapped()
        }
    }
}
