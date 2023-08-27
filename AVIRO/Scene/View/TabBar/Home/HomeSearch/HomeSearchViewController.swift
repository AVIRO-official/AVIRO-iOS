//
//  HomeSearchViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/05/26.
//

import UIKit

final class HomeSearchViewController: UIViewController {
    lazy var presenter = HomeSearchPresenter(viewController: self)
    
    lazy var searchField = SearchField()
    
    lazy var placeListTableView = UITableView()
    lazy var noHistoryView = NoHistoryView()
                                      
    lazy var historyTableView = UITableView()
    
    lazy var indicatorView = UIActivityIndicatorView()
    
    /// API 호출 관련해서 다 입력이 끝나면 발동하도록 하는 변수
    var searchTimer: DispatchWorkItem?

    var tapGesture = UITapGestureRecognizer()
    
    var searchFieldTopConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

extension HomeSearchViewController: HomeSearchProtocol {
    func makeLayout() {
        [
            searchField,
            placeListTableView,
            noHistoryView,
            historyTableView,
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // searchField 클릭 시 navigation 위치로 이동시키기 위함
        searchFieldTopConstraint = searchField.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: 15
        )
        searchFieldTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            // searchTextField
            searchField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            
            // placeListTableView
            placeListTableView.topAnchor.constraint(
                equalTo: searchField.bottomAnchor),
            placeListTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            placeListTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            placeListTableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            
            // noHistoryView
            noHistoryView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            noHistoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noHistoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // historyTableView
            historyTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    // MARK: Attribute
    func makeAttribute() {
        makeViewAndTabAttribute()
        makeSearchFieldAttribute()
        makePlaceListTableAttribute()
        makeHistoryTableAttribute()
        
        indicatorView.style = .large
        indicatorView.startAnimating()
        indicatorView.isHidden = true
        indicatorView.color = .gray5
    }
    
    // MARK: How to Show First View
    func howToShowFirstView(_ isShowHistoryTable: Bool) {
        if isShowHistoryTable {
            ShowHistoryTable()
        } else {
            ShowNoHistoryView()
        }
    }
    
    func placeListTableReload() {
        placeListTableView.reloadData()
        indicatorView.isHidden = true
    }
    
    func historyListTableReload() {
        historyTableView.reloadData()
    }
    
    // MARK: After Tapped History Table Cell
    func insertTitleToTextField(_ query: String) {
        searchField.text = query
        
        whenStartSearchingChangedView()
        presenter.initialSearchDataAndCompareAVIROData(query)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: false)
    }
}

extension HomeSearchViewController {
    // MARK: How to Show First View Detail
    private func ShowHistoryTable() {
        historyTableView.isHidden = false
        noHistoryView.isHidden = true
    }
    
    private func ShowNoHistoryView() {
        historyTableView.isHidden = true
        noHistoryView.isHidden = false
    }
    
    private func showPlaceListTable() {
        placeListTableView.isHidden = false
        historyTableView.isHidden = true
        noHistoryView.isHidden = true
    }
    
    // MARK: View and Tab Attribute
    private func makeViewAndTabAttribute() {
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        
        view.backgroundColor = .gray7
        
        navigationItem.title = "검색하기"
        navigationController?.navigationBar.isHidden = false
        setupCustomBackButton()

        // TabBar Controller
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.hiddenTabBarIncludeIsTranslucent(true)
        }
    }

    // MARK: Search Field Attribute
    private func makeSearchFieldAttribute() {
        searchField.delegate = self
        searchField.rightButtonHidden = true
        searchField.makePlaceHolder("어디로 이동할까요?")
        searchField.didTappedLeftButton = { [weak self] in
            self?.whenSearchingAndTppedBackButton()
        }
    }
    
    // MARK: Place List Table Attribute
    private func makePlaceListTableAttribute() {
        placeListTableView.delegate = self
        placeListTableView.dataSource = self
        placeListTableView.register(
            HomeSearchViewTableViewCell.self,
            forCellReuseIdentifier: HomeSearchViewTableViewCell.identifier
        )
        placeListTableView.separatorStyle = .singleLine
        placeListTableView.separatorColor = .gray5
        placeListTableView.isHidden = true
        placeListTableView.tag = 0
    }
    
    // MARK: History Table Attribute
    private func makeHistoryTableAttribute() {
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.register(
            HistoryTableViewCell.self,
            forCellReuseIdentifier: HistoryTableViewCell.identifier
        )
        historyTableView.separatorStyle = .none
        historyTableView.tag = 1
    }
    
    // MARK: 검색 시작할 때 메소드
    private func whenStartSearchingChangedView() {
        self.navigationController?.navigationBar.isHidden = true
        
        searchField.changeLeftButton()
        UIView.animate(withDuration: 0.2) {
            self.showPlaceListTable()
             
            self.searchFieldTopConstraint?.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: 검색 중 뒤로가기 버튼 누를 때 메소드
    private func whenSearchingAndTppedBackButton() {
        self.navigationController?.navigationBar.isHidden = false
                
        searchField.initLeftButton()
        UIView.animate(withDuration: 0.2) {
            self.presenter.checkHistoryTableValues()
            self.placeListTableView.isHidden = true
            
            self.searchFieldTopConstraint?.constant = 15
            self.view.layoutIfNeeded()
        }
    }
}

extension HomeSearchViewController: UITextFieldDelegate {
    // MARK: 검색 시작할 때
    func textFieldDidBeginEditing(_ textField: UITextField) {
        whenStartSearchingChangedView()
     }
    
    // MARK: 실시간 검색
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchField.rightButtonHidden = false
        
        // 중간 배열의 out of index 방지를 위해 & API 요청 횟수를 줄이기 위해

        // 이전 타이머 작업을 취소합니다(있는 경우).
        searchTimer?.cancel()

        // 새로운 타이머 작업을 생성합니다.
        let task = DispatchWorkItem { [weak self] in
            if let text = textField.text {
                if text != "" {
                    self?.presenter.changedColorText = text
                    self?.indicatorView.isHidden = false
                    self?.presenter.initialSearchDataAndCompareAVIROData(text)
                }
            }
        }
        
        
        // 타이머 작업을 저장합니다.
        searchTimer = task

        // 0.5초 후에 작업을 실행합니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
    
}

extension HomeSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return presenter.matchedPlaceModelCount
        case 1:
            return presenter.historyPlaceModelCount
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HomeSearchViewTableViewCell.identifier,
                for: indexPath
            ) as? HomeSearchViewTableViewCell

            guard let data = presenter.matchedPlaceListRow(indexPath.row) else { return UITableViewCell() }

            let title = data.title
            let address = data.address
            let distance = data.distance
            
            var icon: UIImage?
            
            switch (data.allVegan, data.someVegan, data.requestVegan) {
            case (true, _, _):
                icon = UIImage(named: "AllCell")
            case (_, true, _):
                icon = UIImage(named: "SomeCell")
            case (_, _, true):
                icon = UIImage(named: "RequestCell")
            default:
                icon = UIImage(named: "ListCellIcon")
            }
            
            let cellData = MatchedPlaceListCell(
                icon: icon ?? UIImage(named: "ListCellIcon")!,
                title: title,
                address: address,
                distance: distance
            )
            
            let attributedTitle = title.changeColor(changedText: presenter.changedColorText)
            let attributedAddress = address.changeColor(changedText: presenter.changedColorText)
            
            cell?.makeCellData(cellData, attributedTitle: attributedTitle, attributedAddress: attributedAddress)

            cell?.backgroundColor = .gray7
            cell?.selectionStyle = .none

            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HistoryTableViewCell.identifier,
                for: indexPath
            ) as? HistoryTableViewCell
            
            let cellData = presenter.historyPlaceListRow(indexPath.row)
            
            cell?.makeCellData(cellData)
            
            // MARK: Cancel button 클릭 시
            cell?.cancelButtonTapped = { [weak self] in
                self?.presenter.deleteHistoryModel(indexPath)
            }
            
            cell?.backgroundColor = .gray7
            cell?.selectionStyle = .none
            
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch tableView.tag {
        case 0:
            let headerView = PlaceListHeaderView()
            
            headerView.touchedLocationPositionButton = { [weak self] alert in
                self?.present(alert, animated: true)
            }
            
            headerView.touchedSortingByButton = { [weak self] alert in
                self?.present(alert, animated: true)
            }
            
            headerView.touchedCanActiveSort = { [weak self] in
                guard let query = self?.searchField.text else { return }
                self?.presenter.initialSearchDataAndCompareAVIROData(query)
            }
            
            return headerView
        case 1:
            let headerView = HistoryHeaderView()
            
            headerView.deleteAllCell = { [weak self] in
                self?.presenter.deleteHistoryModelAll()
            }
            
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch tableView.tag {
        case 0:
            return 50
        case 1:
            return 50
        default:
            return 50
        }
    }
}

extension HomeSearchViewController: UITableViewDelegate {
    // MARK: ScrollView Did Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if scrollView == placeListTableView {
            // 더 빠른 API 호출을 위한 상수 300
            if offsetY > contentHeight - height {
                let query = searchField.text ?? ""
                presenter.afterPagingSearchAndCompareAVIROData(query)
            }
        }
    }
    
    // MARK: did Select Row At
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:
            presenter.insertHistoryModel(indexPath)
            presenter.checkIsInAVIRO(indexPath)
        case 1:
            presenter.historyTableCellTapped(indexPath)
        default:
            break
        }
    }
}

extension HomeSearchViewController: UIGestureRecognizerDelegate {
    // MARK: 키보드 로직
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is SearchField {
            return false
        }

        view.endEditing(true)
        return true
    }
}
