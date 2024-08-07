//
//  ThridRegistrationViewControll.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/07/13.
//

import UIKit

// MARK: Text
private enum Text: String {
    case title = "이용약관에\n동의해주세요."
    case subtitle = "정책 및 약관을 클릭해 모든 내용을 확인해주세요."
    case next = "다음으로"
    case allAccept = "전체 동의"
    
    case error = "에러"
}

// MARK: Layout
private enum Layout {
    enum Margin: CGFloat {
        case small = 10
        case medium = 20
        case large = 30
        case largeToView = 40
    }
    
    enum Size: CGFloat {
        case termsTableViewHeight = 195
        case nextButtonHeight = 50
        case headrHeight = 55
    }
}

final class ThridRegistrationViewController: UIViewController {

    var presenter: ThridRegistrationPresenter!
    
    // MARK: UI Property Definitions
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = Text.title.rawValue
        label.font = .pretendard(size: 24, weight: .bold)
        label.textColor = .main
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = Text.subtitle.rawValue
        label.font = .pretendard(size: 14, weight: .regular)
        label.textColor = .gray1
        
        return label
    }()
    
    private lazy var termsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            TermsTableCell.self,
            forCellReuseIdentifier: TVIdentifier.termsTableCell.rawValue
        )
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .gray6
        tableView.layer.cornerRadius = 26
        
        return tableView
    }()
    
    private lazy var allAcceptButton: UIButton = {
        let button = UIButton()
        
        button.setImage(
            UIImage.allApproveCondition.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .gray4
        button.addTarget(
            self,
            action: #selector(allAcceptButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
        
    private lazy var nextButton: NextPageButton = {
        let button = NextPageButton()
        
        button.setTitle(Text.next.rawValue, for: .normal)
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(tappedNextButton),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

extension ThridRegistrationViewController: ThridRegistrationProtocol {
    // MARK: Set up func
    func setupLayout() {
        [
            titleLabel,
            subtitleLabel,
            termsTableView,
            nextButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Layout.Margin.largeToView.rawValue
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.Margin.large.rawValue
            ),
            
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Layout.Margin.small.rawValue
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            
            termsTableView.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            termsTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.Margin.large.rawValue
            ),
            termsTableView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: Layout.Margin.large.rawValue
            ),
            termsTableView.heightAnchor.constraint(
                equalToConstant: Layout.Size.termsTableViewHeight.rawValue
            ),
            
            nextButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Layout.Margin.largeToView.rawValue
            ),
            nextButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.Margin.medium.rawValue
            ),
            nextButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.Margin.medium.rawValue
            ),
            nextButton.heightAnchor.constraint(
                equalToConstant: Layout.Size.nextButtonHeight.rawValue
            )
        ])
    }
    
    func setupAttribute() {
        view.backgroundColor = .gray7
        setupBack(true)
    }
    
    // MARK: UI Interactions
    @objc private func tappedNextButton() {
        presenter.pushUserInfo()
    }

    @objc private func allAcceptButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        sender.tintColor = sender.isSelected ? .main : .gray4
        presenter.allAcceptButtonTapped(sender.isSelected)

        termsTableView.reloadData()
        
        nextButton.isEnabled = sender.isSelected
    }
    
    // MARK: Push Interactions
    func pushFinalRegistrationView() {
        DispatchQueue.main.async { [weak self] in
            let viewController = FinalRegistrationViewController()
            
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: Alert Interactions
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

// MARK: UITableViewDelegate
extension ThridRegistrationViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = tableView.backgroundColor
        
        let allAcceptLabel = UILabel()
        allAcceptLabel.text = Text.allAccept.rawValue
        allAcceptLabel.font = .pretendard(size: 20, weight: .semibold)
        allAcceptLabel.textColor = .gray0
        
        [
            allAcceptLabel,
            allAcceptButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            allAcceptButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor
            ),
            allAcceptButton.topAnchor.constraint(
                equalTo: headerView.topAnchor,
                constant: Layout.Margin.small.rawValue
            ),
            allAcceptButton.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -Layout.Margin.small.rawValue
            ),
            
            allAcceptLabel.leadingAnchor.constraint(
                equalTo: allAcceptButton.trailingAnchor,
                constant: Layout.Margin.small.rawValue
            ),
            allAcceptLabel.centerYAnchor.constraint(
                equalTo: allAcceptButton.centerYAnchor
            )
        ])
        
        return headerView
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        Layout.Size.headrHeight.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let url = URL(string: Policy.termsOfService.rawValue) {
                showWebView(with: url)
            }
        case 1:
            if let url = URL(string: Policy.privacy.rawValue) {
                showWebView(with: url)
            }
        case 2:
            if let url = URL(string: Policy.location.rawValue) {
                showWebView(with: url)
            }
        default:
            break
        }
    }
}

// MARK: UITableViewDataSource
extension ThridRegistrationViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter.terms.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TVIdentifier.termsTableCell.rawValue,
            for: indexPath
        ) as? TermsTableCell
        
        let term = presenter.terms[indexPath.row]
        
        cell?.selectionStyle = .none
        cell?.backgroundColor = termsTableView.backgroundColor
        
        cell?.setupCellData(check: term.1, term: term.0.rawValue)
        
        cell?.checkButtonTapped = { [weak self] in
            self?.presenter.clickedTerm(at: indexPath.row)
            self?.checkAllRequiredTerms()
        }
                
        return cell ?? UITableViewCell()
    }
    
    private func checkAllRequiredTerms() {
        let result = presenter.checkAllRequiredTerms()
        
        allAcceptButton.tintColor = result ? .main : .gray4

        nextButton.isEnabled = result
    }
}
