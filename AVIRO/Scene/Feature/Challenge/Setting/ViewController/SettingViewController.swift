//
//  MyPageViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/05/23.
//

import UIKit

private enum Text: String {
    case title = "설정"

    case cancel = "취소"

    case logoutTitle = "로그아웃 하시겠어요?"
    case logoutAction = "로그아웃"
    case withdrawalTitle = "정말로 어비로를 떠나시는 건가요?"
    case withdrawalSubtitle = "회원탈퇴 이후, 내가 등록한 가게와 댓글은\n사라지지 않지만, 다시 볼 수 없어요.\n정말로 탈퇴하시겠어요?"
    case withdrawalAction = "탈퇴하기"
    
    case error = "에러"
}

enum SettingsSection: Int, CaseIterable {
    case setting
    case information
    case account
    
    var rows: [SettingsRow] {
        switch self {
        case .setting:
            return [
                .editNickname,
                .inquiries,
                .instagram
            ]
        case .information:
            return [
                .termsOfService,
                .privacyPolicy,
                .locationPolicy,
                .openSorce,
                .thanksTo
            ]
        case .account:
            return [
                .logout,
                .versionInfo
            ]
        }
    }
}

enum SettingsRow: String {
    case editNickname = "닉네임 수정하기"
    case inquiries = "문의사항"
    case instagram = "인스타그램"
    
    case termsOfService = "서비스 이용약관"
    case privacyPolicy = "개인정보 수집 및 이용"
    case locationPolicy = "위치정보 수집 및 이용"
    case openSorce = "오픈소스 라이선스"
    case thanksTo = "감사한분들"
    
    case logout = "로그아웃"
    case versionInfo = "버전 정보"
}

final class SettingViewController: UIViewController {
    private lazy var presenter = SettingViewPresenter(viewController: self)
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        
        indicatorView.style = .large
        indicatorView.startAnimating()
        indicatorView.isHidden = true
        indicatorView.color = .gray0
        
        return indicatorView
    }()
    
    private lazy var blurEffectView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .gray6.withAlphaComponent(0.3)
        view.frame = self.view.bounds
        view.isHidden = true
        
        return view
    }()
    
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.register(
            SettingCell.self,
            forCellReuseIdentifier: SettingCell.identifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .gray6
        tableView.rowHeight = 50
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
}

extension SettingViewController: MyPageViewProtocol {
    func setupLayout() {
       [
            settingTableView,
            blurEffectView,
            indicatorView
       ].forEach {
           $0.translatesAutoresizingMaskIntoConstraints = false
           self.view.addSubview($0)
       }
        
        NSLayoutConstraint.activate([
            settingTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            settingTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            settingTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            settingTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    func setupAttribute() {
        view.backgroundColor = .gray7
        self.setupBack(true)
                
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        
        navigationItem.title = Text.title.rawValue
        navigationController?.navigationBar.isHidden = false
    }
    
    func switchIsLoading(with loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            print("Test")
            self?.indicatorView.isHidden = !loading
            self?.blurEffectView.isHidden = !loading
        }
    }
    
    private func whenTappedCell(with settingsRow: SettingsRow) {
        switch settingsRow {
        case .editNickname:
            whenTappedEditNickName()
        case .inquiries:
            whenTappedInquiries()
        case .instagram:
            whenTappedInstagram()
            
        case .termsOfService:
            whenTappedTermsOfService()
        case .privacyPolicy:
            whenTappedPrivacyPolicy()
        case .locationPolicy:
            whenTappedLocationPlicy()
        case .openSorce:
            whenTappedOpenSorce()
        case .thanksTo:
            whenTappedThanksTo()
            
        case .logout:
            whenTappedLogOut()
        default:
            break
        }
        
    }
    
    private func whenTappedEditNickName() {
        let vc = NickNameChangebleViewController()
        let presenter = NickNameChangeblePresenter(viewController: vc)
        
        vc.presenter = presenter
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func whenTappedInquiries() {
        showMailView()
    }
    
    private func whenTappedInstagram() {
        let aviro = URL(string: "https://www.instagram.com/aviro.kr.official/")!
        UIApplication.shared.open(aviro)
    }
    
    private func whenTappedTermsOfService() {
        if let url = URL(string: Policy.termsOfService.rawValue) {
            showWebView(with: url)
        }
    }
    
    private func whenTappedPrivacyPolicy() {
        if let url = URL(string: Policy.privacy.rawValue) {
            showWebView(with: url)
        }
    }
    
    private func whenTappedLocationPlicy() {
        if let url = URL(string: Policy.location.rawValue) {
            showWebView(with: url)
        }
    }
    
    private func whenTappedOpenSorce() {
        let licenseVC =  LicensesViewController()
        navigationController?.pushViewController(licenseVC, animated: true)
    }
    
    private func whenTappedThanksTo() {
        if let url = URL(string: Policy.thanksto.rawValue) {
            showWebView(with: url)
        }
    }
    
    private func whenTappedLogOut() {
        let cancelAction: AlertAction = (
            title: Text.cancel.rawValue,
            style: .default,
            handler: nil
        )
        
        let logoutAction: AlertAction = (
            title: Text.logoutAction.rawValue,
            style: .destructive,
            handler: {
                self.presenter.whenAfterLogout()
            }
        )
        
        showAlert(
            title: Text.logoutTitle.rawValue,
            message: nil,
            actions: [cancelAction, logoutAction]
        )
    }
    
    private func whenTappedWithdrawal() {
        let cancelAction: AlertAction = (
            title: Text.cancel.rawValue,
            style: .default,
            handler: nil
        )
        
        let withdrawalAction: AlertAction = (
            title: Text.withdrawalAction.rawValue,
            style: .destructive,
            handler: {
                self.presenter.whenAfterWithdrawal()
            }
        )
        
        showAlert(
            title: Text.withdrawalTitle.rawValue,
            message: Text.withdrawalSubtitle.rawValue,
            actions: [cancelAction, withdrawalAction]
        )
    }
    
    func pushLoginViewController(with: LoginRedirectReason) {
        let vc = LoginViewController()
        let presenter = LoginViewPresenter(viewController: vc)
        vc.presenter = presenter

        switch with {
        case .logout:
            presenter.whenAfterLogout = true
        case .withdrawal:
            presenter.whenAfterWithdrawal = true

        }
        
        let rootViewController = UINavigationController(rootViewController: vc)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController = rootViewController
            windowScene.windows.first?.makeKeyAndVisible()
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

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionType = SettingsSection(rawValue: section) else { return 0 }
        return sectionType.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell
        
        if let sectionType = SettingsSection(rawValue: indexPath.section) {
            let rowType = sectionType.rows[indexPath.row]
            
            cell?.selectionStyle = .none
            
            cell?.dataBinding(rowType)
            cell?.tappedAfterSettingValue = { [weak self] settingValue in
                self?.whenTappedCell(with: settingValue)
            }
        }
        
        return cell ?? UITableViewCell()
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == SettingsSection.account.rawValue {
            return makeUserWithdrwalView()
        }
        return nil
    }
    
    private func makeUserWithdrwalView() -> UIView {
        let footerView = UIView()
        footerView.backgroundColor = .gray6
        
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        
        let attributedString = NSMutableAttributedString(string: "회원탈퇴")
        attributedString.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(.gray2, for: .normal)
        button.titleLabel?.font = .pretendard(size: 16, weight: .medium)
        button.addTarget(self, action: #selector(withdrawalTapped), for: .touchUpInside)
        
        footerView.addSubview(button)
        
        return footerView
    }
    
    @objc private func withdrawalTapped() {
        self.whenTappedWithdrawal()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == SettingsSection.account.rawValue {
            return 50
        }
        return 10
    }
}
