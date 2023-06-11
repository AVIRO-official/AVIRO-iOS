//
//  InrollPlaceViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/05/22.
//

import UIKit

final class InrollPlaceViewController: UIViewController {
    
    lazy var presenter = InrollPlacePresenter(viewController: self)
    
    // scrollView
    var scrollView = UIScrollView()
    
    // required / optional refer
    var requiredTitleLabel = UILabel()
    var requriedLocationLabel = UILabel()
    var requriedCategoryLabel = UILabel()
    var optionalPhoneLabel = UILabel()
    var requriedDetailLabel = UILabel()
    var requriedMenuLabel = UILabel()
    
    // store title refer
    var storeTitleExplanation = UILabel()
    var storeTitleField = InrollTextField()
    var storeTitleExplanationStackView = UIStackView()
    var storeTitleStackView = UIStackView()
    
    // store location refer
    var storeLocationExplanation = UILabel()
    var storeLocationField = InrollTextField()
    var storeLocationExplanationStackView = UIStackView()
    var storeLocationStackView = UIStackView()
    
    // store category refer
    var storeCategoryExplanation = UILabel()
    var storeCategoryField = InrollTextField()
    var storeCategoryExplanationStackView = UIStackView()
    var storeCategoryStackView = UIStackView()
    
    // store phone refer
    var storePhoneExplanation = UILabel()
    var storePhoneField = InrollTextField()
    var storePhoneExplanationStackView = UIStackView()
    var storePhoneStackView = UIStackView()
    
    // vegan detail refer
    var veganDetailExplanation = UILabel()
    var allVegan = SelectVeganButton()
    var someMenuVegan = SelectVeganButton()
    var ifRequestPossibleVegan = SelectVeganButton()
    var veganDetailExplanationStackView = UIStackView()
    var veganButtonStackView = UIStackView()
    var veganDetailStackView = UIStackView()
    
    // 동적 뷰 layout
    var veganDetailStackViewBottomL: NSLayoutConstraint!
    var tableHeaderViewL: [NSLayoutConstraint]!
    var allAndVeganMenuL: [NSLayoutConstraint]!
    var howToRequestVeganMenuTableViewL: [NSLayoutConstraint]!
    
    var veganTableViewHeightConstraint: NSLayoutConstraint!
    var requestVeganTableViewHeightConstraint: NSLayoutConstraint!
    
    var veganTableHeightPlusValueTotal = 0
    var requestVeganTableHeightPlusValueTotal = 0
    
    // TableView Header View
    var veganMenuExplanation = UILabel()
    var veganMenuExplanationStackView = UIStackView()
    var veganMenuPlusButton = UIButton()
    var veganMenuHeaderStackView = UIStackView()
    
    // ALL 비건을 클릭할 때
    // 비건 메뉴 포함을 클릭할 때
    var veganMenuTableView = UITableView()
    
    // 요청하면 비건을 클릭할 떄
    var howToRequestVeganMenuTableView = UITableView()
    
    var reportStoreButton = ReportButton()
    
    var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: 검색 후 데이터 불러오기
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectedPlace(_:)),
            name: NSNotification.Name("selectedPlace"),
            object: nil
        )
        
        // 키보드에 따른 view 높이 변경
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 키보드에 따른 view 높이 변경
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("selectedPlace"), object: nil)
    }
    
    // MARK: refreshData
    func refreshData() {
        storeTitleField.text = ""
        storeLocationField.text = ""
        storeCategoryField.text = ""
        storePhoneField.text = ""
        allVegan.backgroundColor = .white
        someMenuVegan.backgroundColor = .white
        ifRequestPossibleVegan.backgroundColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
        reportStoreButton.isEnabled = false
        
        allVegan.setImage(UIImage(named: "올비건No"), for: .normal)
        allVegan.setTitleColor(.separateLine, for: .normal)
        
        someMenuVegan.setImage(UIImage(named: "썸비건No"), for: .normal)
        someMenuVegan.setTitleColor(.separateLine, for: .normal)
        
        ifRequestPossibleVegan.setImage(UIImage(named: "요청비건No"), for: .normal)
        ifRequestPossibleVegan.setTitleColor(.separateLine, for: .normal)
        
        updateViewChanges(.offAll)
    }
}

extension InrollPlaceViewController: InrollPlaceProtocol {
    // MARK: 전체 Layout
    func makeLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        storeTitleStackViewLayout()
        storeLocationStackViewLayout()
        storeCategoryStackviewLayout()
        storePhoneStackviewLayout()
        veganDetailStackViewLayout()
        veganTableHeaderViewLayout()

        stackViewLayout()
    }
    
    // MARK: 전체 Attribute
    func makeAttribute() {
        // navigation & view 관련
        navigationItem.title = "가게 제보하기"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainTitle!]
        let rightBarButton = UIBarButtonItem(
            title: "제보하기",
            style: .plain,
            target: self,
            action: #selector(reportStore)
        )
        navigationItem.rightBarButtonItem = rightBarButton
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        view.backgroundColor = .white
        view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        
        // report button & navigaitonRightBarButton
        reportStoreButton.isEnabled = false
        
        navigationItem.rightBarButtonItem?.isEnabled = false

        // required / optional
        requiredAndOptionalAttribute()
        
        // store title refer
        storeTitleReferAttribute()
        
        // store location refer
        storeLocationReferAttribute()
        
        // store category refer
        storeCategoryReferAttribute()
        
        // store phone refer
        storePhoneReferAttribute()
        
        // vegan detail refer
        veganDetailReferAttribute()
        
        // vegan Header View refer
        veganHeaderViewAttribute()
        
        // report button
        reportStoreButton.setTitle("이 가게 제보하기", for: .normal)
        reportStoreButton.addTarget(self,
                                    action: #selector(reportStore),
                                    for: .touchUpInside
        )
        reportStoreButton.layer.cornerRadius = 28
        
        reportStoreButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        veganMenuTableView.isHidden = true
        howToRequestVeganMenuTableView.isHidden = true
        
        veganMenuTableView.register(
            VeganMenuTableViewCell.self,
            forCellReuseIdentifier: VeganMenuTableViewCell.identifier
        )
        
        veganMenuTableView.dataSource = self
        veganMenuTableView.tag = 0
        veganMenuTableView.isScrollEnabled = false
        veganMenuTableView.separatorStyle = .none
        
        howToRequestVeganMenuTableView.register(
            IfRequestVeganMenuTableViewCell.self,
            forCellReuseIdentifier: IfRequestVeganMenuTableViewCell.identifier
        )
        
        howToRequestVeganMenuTableView.dataSource = self
        howToRequestVeganMenuTableView.tag = 1
        howToRequestVeganMenuTableView.isScrollEnabled = false
        howToRequestVeganMenuTableView.separatorStyle = .none
        
        veganMenuPlusButton.addTarget(self, action: #selector(plusCell), for: .touchUpInside)
            
    }
    
    // MARK: ReloadTableView
    func reloadTableView(_ checkTable: Bool) {
        if checkTable {
            veganMenuTableView.reloadData()
        } else {
            howToRequestVeganMenuTableView.reloadData()
        }
    }
}

extension InrollPlaceViewController {
    // MARK: Final Report Function
    @objc func reportStore() {
        presenter.reportData()
        refreshData()
        
        requestVeganTableViewHeightConstraint.constant -= CGFloat(integerLiteral: requestVeganTableHeightPlusValueTotal)
        veganTableViewHeightConstraint.constant -= CGFloat(integerLiteral: veganTableHeightPlusValueTotal)

        requestVeganTableHeightPlusValueTotal = 0
        veganTableHeightPlusValueTotal = 0
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.view.alpha = 0.8
        }, completion: { [weak self] _ in
            self?.tabBarController?.selectedIndex = 0
            let homeViewController = self?.tabBarController?.viewControllers?[0] as? UINavigationController
            homeViewController?.popToRootViewController(animated: false)

            UIView.animate(withDuration: 0.5) {
                self?.view.alpha = 1
            }
        })
    }
    // MARK: ALL 비건 클릭 시
    @objc func clickedAllVeganButton() {
        // ALL 비건 클릭 on
        if !presenter.allVegan {
            updateVeganState(.allVeganClicked)
            updateViewChanges(.allVeganClicked)
            
            isPossibleReportButton()
        } else {
        // ALL 비건 클릭 off
            updateVeganState(.offAll)
            updateViewChanges(.offAll)
            
            isNegativeReportButton()
        }
    }
    // MARK: 비건 메뉴 포함 클릭 시
    @objc func clickedSomeMenuVeganButton() {
        // 비건 메뉴 포함, 요청하면 비건 둘다 클릭 안 되어있을 때
        if !presenter.someMenuVegan && !presenter.ifRequestVegan {
            updateVeganState(.onlySomeVeganClicked)
            updateViewChanges(.onlySomeVeganClicked)

            isPossibleReportButton()
            // 비건 메뉴 포함만 안 되있고, 요청하면 비건은 눌러져있을 때
        } else if !presenter.someMenuVegan && presenter.ifRequestVegan {
            updateVeganState(.someAndReqeustVeganClicked)
            updateViewChanges(.someAndReqeustVeganClicked)

            isPossibleReportButton()
            // 둘 다 눌러져 있을 때
        } else if presenter.someMenuVegan && presenter.ifRequestVegan {
            updateVeganState(.onlyRequestVeganClicked)
            updateViewChanges(.onlyRequestVeganClicked)

            // 비건 메뉴만 눌러져 있을 때
        } else {
            updateVeganState(.offAll)
            updateViewChanges(.offAll)

            isNegativeReportButton()
        }
    }
    // MARK: 요청하면 비건 클릭 시
    @objc func clickedIfRequestPossibleVebanButton() {
        // 비건 메뉴 포함, 요청하면 비건 둘다 클릭 안 되어있을 때
        if !presenter.ifRequestVegan && !presenter.someMenuVegan {
            updateVeganState(.onlyRequestVeganClicked)
            updateViewChanges(.onlyRequestVeganClicked)

            isPossibleReportButton()

            // 비건 메뉴 포함만 눌러져 있을 때
        } else if !presenter.ifRequestVegan && presenter.someMenuVegan {
            updateVeganState(.someAndReqeustVeganClicked)
            updateViewChanges(.someAndReqeustVeganClicked)

            isPossibleReportButton()
            // 둘다 눌러져 있을 때
        } else if presenter.ifRequestVegan && presenter.someMenuVegan {
            updateVeganState(.onlySomeVeganClicked)
            updateViewChanges(.onlySomeVeganClicked)

            isPossibleReportButton()
            // 혼자만 눌러져 있을 때
        } else {
            updateVeganState(.offAll)
            updateViewChanges(.offAll)

            isNegativeReportButton()
        }
    }
    
    // MARK: TableView Cell 데이터 입력 창 추가
    @objc func plusCell() {
        if veganMenuTableView.isHidden {
            presenter.plusCell(false)
            requestVeganTableHeightPlusValueTotal += Int(storeTitleField.intrinsicContentSize.height * 2 + 25)
            requestVeganTableViewHeightConstraint.constant += storeTitleField.intrinsicContentSize.height * 2 + 25
            view.layoutIfNeeded()
        } else {
            presenter.plusCell(true)
            veganTableHeightPlusValueTotal += Int(storeTitleField.intrinsicContentSize.height + 15)
            veganTableViewHeightConstraint.constant += storeTitleField.intrinsicContentSize.height + 15
            view.layoutIfNeeded()
        }
    }
    
    // MARK: 검색 후 데이터 불러오기 작업
    @objc func selectedPlace(_ notification: Notification) {
        guard let selectedPlace = notification.userInfo?["selectedPlace"] as? PlaceListModel else { return }
        
        presenter.storeNomalData = selectedPlace
        
        storeTitleField.text = selectedPlace.title
        storeLocationField.text = selectedPlace.address
        storeCategoryField.text = selectedPlace.category
        storePhoneField.text = selectedPlace.phone
    }
    
    // MARK: Report 버튼 작업
    func isPossibleReportButton() {
        if storeTitleField.text != "" {
            reportStoreButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // MARK: Report 버튼 off
    func isNegativeReportButton() {
        reportStoreButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

extension InrollPlaceViewController: UITextFieldDelegate {
    // MARK: Store Location Search Start
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == storeTitleField {
            let viewController = PlaceListViewController()
            
            navigationController?.pushViewController(viewController, animated: true)
            return false
        }
        return true
    }
}

// MARK: TableView Data Source
extension InrollPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return presenter.notRequestMenu.count
        case 1:
            return presenter.requestMenu.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: VeganMenuTableViewCell.identifier
                , for: indexPath
            ) as? VeganMenuTableViewCell
            
            cell?.selectionStyle = .none
            
            cell?.menuTextField.addTarget(
                self,
                action: #selector(veganMenuTextDidChange(_:)),
                for: .editingChanged
            )
            cell?.priceTextField.addTarget(
                self,
                action: #selector(veganMenuPriceTextDidChange(_:)),
                for: .editingChanged
            )
            
            let name = presenter.notRequestMenu[indexPath.row].menu
            let price = presenter.notRequestMenu[indexPath.row].price
            cell?.dataBinding(name, price)
            
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: IfRequestVeganMenuTableViewCell.identifier,
                for: indexPath
            ) as? IfRequestVeganMenuTableViewCell
            
            cell?.selectionStyle = .none
            
            cell?.menuTextField.addTarget(
                self,
                action: #selector(requestMenuTextDidChange(_:)),
                for: .editingChanged
            )
            cell?.priceTextField.addTarget(
                self,
                action: #selector(requestPriceTextDidChange(_:)),
                for: .editingChanged
            )
            cell?.detailTextField.addTarget(
                self,
                action: #selector(requestDetailTextDidChahge(_:)),
                for: .editingChanged)
            
            let name = presenter.requestMenu[indexPath.row].menu
            let price = presenter.requestMenu[indexPath.row].price
            let detail = presenter.requestMenu[indexPath.row].howToRequest
            let check = presenter.requestMenu[indexPath.row].isCheck
            
            cell?.dataBinding(name, price, detail, check)
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

// MARK: Table TextField 데이터 관련
extension InrollPlaceViewController {
    @objc func veganMenuTextDidChange(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: veganMenuTableView)
        if let textFieldIndexPath = veganMenuTableView.indexPathForRow(at: pointInTable) {
            presenter.notRequestMenu[textFieldIndexPath.row].menu = textField.text ?? ""
        }
    }
    
    @objc func veganMenuPriceTextDidChange(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: veganMenuTableView)
        if let textFieldIndexPath = veganMenuTableView.indexPathForRow(at: pointInTable) {
            presenter.notRequestMenu[textFieldIndexPath.row].price = textField.text ?? ""
        }
    }
    
    @objc func requestMenuTextDidChange(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: howToRequestVeganMenuTableView)
        if let textFieldIndexPath = howToRequestVeganMenuTableView.indexPathForRow(at: pointInTable) {
            presenter.requestMenu[textFieldIndexPath.row].menu = textField.text ?? ""
        }
    }
    
    @objc func requestPriceTextDidChange(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: howToRequestVeganMenuTableView)
        if let textFieldIndexPath = howToRequestVeganMenuTableView.indexPathForRow(at: pointInTable) {
            presenter.requestMenu[textFieldIndexPath.row].price = textField.text ?? ""
        }
    }
    
    @objc func requestDetailTextDidChahge(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: howToRequestVeganMenuTableView)
        if let textFieldIndexPath = howToRequestVeganMenuTableView.indexPathForRow(at: pointInTable) {
            presenter.requestMenu[textFieldIndexPath.row].howToRequest = textField.text ?? ""
            if textField.text != "" {
                presenter.requestMenu[textFieldIndexPath.row].isCheck = true
            }
        }
    }
}

// MARK: 다른곳 클릭할 때 키보드 없애기
extension InrollPlaceViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        view.endEditing(true)
    }
    
    // MARK: 키보드 나타남에 따라 view 동적으로 보여주기
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
            let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardRectangle.height - tabBarHeight))
                }
            )
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.transform = .identity
    }
}
