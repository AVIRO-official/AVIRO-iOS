//
//  EditMenuViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/25.
//

import UIKit

private enum Text: String {
    case error = "에러"
}

final class EditMenuViewController: UIViewController {
    weak var tabBarDelegate: TabBarSettingDelegate?
    lazy var presenter = EditMenuPresenter(viewController: self)
    
    private lazy var editMenuTopView = EditMenuTopView()
    
    private lazy var editMenuBottomView =  EditMenuBottomView()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
    }
}

extension EditMenuViewController: EditMenuProtocol {
    func makeLayout() {
        [
            editMenuTopView,
            editMenuBottomView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            editMenuTopView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 15),
            editMenuTopView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            editMenuTopView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            editMenuBottomView.topAnchor.constraint(
                equalTo: editMenuTopView.bottomAnchor, constant: 15),
            editMenuBottomView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            editMenuBottomView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            editMenuBottomView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -25)
        ])
        
        [
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func makeAttribute() {
        self.view.backgroundColor = .gray7
        self.scrollView.backgroundColor = .gray6
        
        self.setupBack()
        
        navigationController?.navigationBar.isHidden = false
        
        navigationItem.title = "메뉴 수정하기"
        
        let rightBarButton = UIBarButtonItem(title: "수정하기", style: .plain, target: self, action: #selector(editMenu))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
//        if let tabBarController = self.tabBarController as? TabBarViewController {
//            tabBarController.hiddenTabBar(true)
//        }
        
        editMenuBottomView.setTableViewDelegate(self)
        
        let backButton = UIButton()
        
        backButton.setImage(
            UIImage.back,
            for: .normal
        )
        backButton.addTarget(
            self,
            action: #selector(backButtonTapped(_:)),
            for: .touchUpInside
        )
        backButton.frame = .init(
            x: 0,
            y: 0,
            width: 24,
            height: 24
        )
        
        let barButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        tabBarDelegate?.isHidden = (false, true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editMenu() {
        presenter.filteringDataSet()
    }
    
    func updateEditMenuButton(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
    
    func handleClosure() {
        editMenuTopView.veganOptionsTapped = { [weak self] (text, selected) in
            self?.presenter.changedVeganOption(text, selected)
        }
        
        editMenuBottomView.plusButtonTapped = { [weak self] in
            self?.presenter.plusMenu()
        }
    }
    
    func makeGesture() {
        view.addGestureRecognizer(tapGesture)
            
        tapGesture.delegate = self
    }
    
    func keyboardWillShow(height: CGFloat) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        
        view.layoutIfNeeded()
    }
    
    func keyboardWillHide() {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        
        view.layoutIfNeeded()
    }
    
    func dataBindingTopView(isAll: Bool, isSome: Bool, isRequest: Bool) {
        editMenuTopView.dataBinding(isAll: isAll, isSome: isSome, isRequest: isRequest)
    }
    
    func dataBindingBottomView(_ isPresentingDefaultTable: Bool) {
        editMenuBottomView.initMenuTableView(isPresentingDefaultTable, presenter.menuArrayCount)
    }
    
    func updateMenuTableView(_ isPresentingDefaultTable: Bool) {
        if isPresentingDefaultTable {
            editMenuBottomView.changeMenuTable(isPresentingDefaultTable, presenter.veganMenuCount)
        } else {
            editMenuBottomView.changeMenuTable(isPresentingDefaultTable, presenter.requestVeganMenuCount)
        }
    }
    
    func menuTableReload(_ isPresentingDefaultTable: Bool) {
        editMenuBottomView.menuTableReload(isPresentingDefaultTable)
    }
    
    func popViewController() {
        DispatchQueue.main.async { [weak self] in
            self?.tabBarDelegate?.isHidden = (false, true)
            self?.navigationController?.popViewController(animated: true)
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

extension EditMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return presenter.veganMenuCount
        case 1:
            return presenter.requestVeganMenuCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NormalTableViewCell.identifier,
                for: indexPath
            ) as? NormalTableViewCell

            guard let menuData = presenter.checkVeganMenuData(indexPath) else { return UITableViewCell() }
                        
            cell?.setData(menu: menuData.menu,
                          price: menuData.price
            )
            
            cell?.selectionStyle = .none
            
            // MARK: DataBinding
            cell?.editingMenuField = { [weak self] menu in
                self?.presenter.editingMenuField(menu, indexPath)
            }
            
            cell?.editingPriceField = { [weak self] price in
                self?.presenter.editingPriceField(price, indexPath)
            }
            
            cell?.onMinusButtonTapped = { [weak self] in
                self?.presenter.deleteMenu(indexPath)
            }

            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RequestTableViewCell.identifier,
                for: indexPath
            ) as? RequestTableViewCell
            
            guard let menuData = presenter.checkRequestVeanMenuData(indexPath) else { return UITableViewCell() }
                                    
            cell?.setData(menu: menuData.menu,
                          price: menuData.price,
                          request: menuData.howToRequest,
                          isSelected: menuData.isCheck,
                          isEnabled: menuData.isEnabled
            )
            
            cell?.selectionStyle = .none

            // MARK: DataBinding
            cell?.editingMenuField = { [weak self] menu in
                self?.presenter.editingMenuField(menu, indexPath)
            }
            
            cell?.editingPriceField = { [weak self] price in
                self?.presenter.editingPriceField(price, indexPath)
            }
            
            cell?.onRequestButtonTapped = { [weak self] selected in
                self?.presenter.editingRequestButton(selected, indexPath)
            }
            
            cell?.editingRequestField = { [weak self] request in
                self?.presenter.editingRequestField(request, indexPath)
            }
            
            cell?.onMinusButtonTapped = { [weak self] in
                self?.presenter.deleteMenu(indexPath)
            }
            
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

extension EditMenuViewController: UIGestureRecognizerDelegate {
    // MARK: 키보드 로직
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is EditMenuTopView || touch.view is UINavigationBar {
               view.endEditing(true)
               return true
           } else {
               return false
           }
    }
}
