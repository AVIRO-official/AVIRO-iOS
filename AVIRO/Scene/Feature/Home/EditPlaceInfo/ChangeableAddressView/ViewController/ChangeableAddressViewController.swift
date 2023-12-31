//
//  ChangeableAddressViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/27.
//

import UIKit

import NMapsMap

private enum Segmented: String {
    case address = "주소 검색"
    case map = "지도에서 검색"
}

private enum Text: String {
    case error = "에러"
}

final class ChangeableAddressViewController: UIViewController {
    lazy var presenter = ChangeableAddressPresenter(viewController: self)
    
    private let items = [
        Segmented.address.rawValue,
        Segmented.map.rawValue
    ]
    
    private lazy var topLine: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray5
        
        return view
    }()
    
    private lazy var segmentedControl: UnderlineSegmentedControl = {
        let segmented = UnderlineSegmentedControl(items: items)
        
        segmented.setAttributedTitle()
        segmented.backgroundColor = .gray7
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentedChanged(segment:)), for: .valueChanged)
        
        return segmented
    }()
    
    private lazy var editLocationDetailTextView: EditLocationAddressTextView = {
        let view = EditLocationAddressTextView()
        
        view.searchAddress = { [weak self] text in
            self?.presenter.whenAfterSearchAddress(text)
        }
        
        return view
    }()
    
    private lazy var editLocationDetailMapView: EditLocationAddressMapView = {
        let view = EditLocationAddressMapView()
        
        view.isChangedCoordinate = { [weak self] coordinate in
            self?.presenter.whenAfterChangedCoordinate(coordinate)
        }
        
        view.isTappedEditButtonWhemMapView = { [weak self] in
            self?.presenter.editAddressWhenMapView()
        }
        
        return view
    }()
    
    private lazy var tapGesture = UIGestureRecognizer()
    private lazy var leftSwipeGesture = UISwipeGestureRecognizer()
    private lazy var rightSwipeGesture = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
}

extension ChangeableAddressViewController: ChangebleAddressProtocol {
    func makeLayout() {
        [
            topLine,
            segmentedControl,
            editLocationDetailTextView,
            editLocationDetailMapView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topLine.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            segmentedControl.topAnchor.constraint(equalTo: topLine.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            editLocationDetailTextView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            editLocationDetailTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editLocationDetailTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            editLocationDetailTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            editLocationDetailMapView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            editLocationDetailMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editLocationDetailMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            editLocationDetailMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func makeAttribute() {
        self.view.backgroundColor = .gray7
        
        self.setupBack()
        
        navigationItem.title = "주소"
        
        activeTextSearch()
        
        editLocationDetailTextView.setTableViewDataSource(self)
        editLocationDetailTextView.setTableViewDelegate(self)
    }
    
    func makeGesture() {
        [
            tapGesture,
            leftSwipeGesture,
            rightSwipeGesture
        ].forEach {
            self.view.addGestureRecognizer($0)
        }
        
        tapGesture.delegate = self
        leftSwipeGesture.direction = .left
        rightSwipeGesture.direction = .right
        
        leftSwipeGesture.addTarget(self, action: #selector(swipeGestureActive(_:)))
        rightSwipeGesture.addTarget(self, action: #selector(swipeGestureActive(_:)))
    }
    
    @objc private func swipeGestureActive(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right && segmentedControl.selectedSegmentIndex != 0 {
            segmentedControl.selectedSegmentIndex -= 1
        } else if gesture.direction == .left && segmentedControl.selectedSegmentIndex != 1 {
            segmentedControl.selectedSegmentIndex += 1
        }
        
        whenActiveSegmentedChanged()
    }
    
    @objc private func segmentedChanged(segment: UISegmentedControl) {
        whenActiveSegmentedChanged()
    }
    
    private func whenActiveSegmentedChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            activeTextSearch()
        case 1:
            activeMapSearch()
        default:
            break
        }
    }
    
    private func activeTextSearch() {
        editLocationDetailTextView.isHidden = false
        editLocationDetailMapView.isHidden = true
    }
    
    private func activeMapSearch() {
        editLocationDetailTextView.isHidden = true
        editLocationDetailMapView.isHidden = false
    }
    
    func dataBindingMap(_ marker: NMFMarker) {
        editLocationDetailMapView.dataBinding(marker)
    }
    
    func afterChangedAddressWhenMapView(_ address: String) {
        DispatchQueue.main.async { [weak self] in
            self?.editLocationDetailMapView.changedAddress(address)
        }
    }
    
    func afterResultShowTable(with totalCount: Int) {
        DispatchQueue.main.async { [weak self] in
            if totalCount == 0 {
                self?.noResultData()
            } else {
                self?.reloadData()
            }
        }
    }
    
    private func reloadData() {
        editLocationDetailTextView.addressTableViewReloadData()
    }
    
    private func noResultData() {
        editLocationDetailTextView.noResultData()
    }
    
    func popViewController() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func whenNoAddressInMap() {
        DispatchQueue.main.async { [weak self] in
            self?.editLocationDetailMapView.whenNoAddressInMap()
        }
    }
    
    func showErrorAlert(with error: String, title: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let title = title {
                self?.showAlert(title: title, message: error)
            } else {
                self?.showAlert(title: Text.error.rawValue, message: error)
            }
        }
    }
}

extension ChangeableAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.addressModelCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EditLocationAddressTextTableViewCell.identifier,
            for: indexPath
        ) as? EditLocationAddressTextTableViewCell
        
        guard presenter.addressModelCount > indexPath.row else {
            return UITableViewCell()
        }
        
        let jusoData = presenter.checkSearchData(indexPath)
        
        guard let roadAddr = jusoData.roadAddr,
              let jibunAddr = jusoData.jibunAddr
        else { return UITableViewCell()}
        
        cell?.dataBinding(
            juso: jusoData,
            attributedRoad: roadAddr.changeColor(changedText: presenter.changedColorText),
            attributedJibun: jibunAddr.changeColor(changedText: presenter.changedColorText)
        )
        
        return cell ?? UITableViewCell()
    }
}

extension ChangeableAddressViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            presenter.whenScrollingTableView()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath)
                as? EditLocationAddressTextTableViewCell
        else { return }
        
        let selecedAddress = cell.selectedCell()
        
        presenter.whenAfterClickedAddress(selecedAddress)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChangeableAddressViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISegmentedControl {
            view.endEditing(true)
            return false
        }
        
        if touch.view is EnrollField || touch.view is UIButton {
            return false
        }
        
        view.endEditing(true)
        return true
    }
}
