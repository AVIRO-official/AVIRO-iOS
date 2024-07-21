//
//  LoginViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/14.
//

import UIKit

// MARK: Text
private enum Text: String {
    case apple = "Apple로 로그인하기"
    case logoutToast = "로그아웃이 완료되었습니다."
    case withdrawalTitle = "회원탈퇴가 완료되었어요."
    case withdrawalMessage = "함께한 시간이 아쉽지만,\n언제든지 돌아오는 문을 열어둘게요.\n어비로의 비건 여정은 계속될 거예요!"
    
    case error = "에러"
}

// MARK: Layout
private enum Layout {
    enum Margin: CGFloat {
        case appleToBottom = 40
        case buttonH = 26.5
    }
    
    enum Size: CGFloat {
        case buttonHeight = 50
    }
}

final class LoginViewController: UIViewController {
    var presenter: LoginViewPresenter!
    
    // MARK: UI Property Definitions
    private lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
       
        imageView.image = .aviroReverse
        
        return imageView
    }()
    
    private lazy var berryMapImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = .berryMap
        
        return imageView
    }()

    private lazy var naverButton: LoginButton = {
        let btn = LoginButton()

        btn.setButtonStyle(type: .naver)
        btn.didTappedButton = { [weak self] in
            // TODO: 함수 위치 변경하기
            self?.presenter.checkMember(type: .naver)
        }
        
        return btn
    }()
    
    private lazy var kakaoButton: LoginButton = {
        let btn = LoginButton()
        
        btn.setButtonStyle(type: .kakao)
        btn.didTappedButton = { [weak self] in
            self?.presenter.checkMember(type: .kakao)
        }

        return btn
    }()
    
    private lazy var googleButton: LoginButton = {
        let btn = LoginButton()
      
        btn.setButtonStyle(type: .google)
        btn.didTappedButton = { [weak self] in
            self?.presenter.checkMember(type: .google)
        }

        return btn
    }()
    
    private lazy var appleButton: LoginButton = {
        let btn = LoginButton()
        
        btn.setButtonStyle(type: .apple)
        btn.didTappedButton = { [weak self] in
            self?.presenter.checkMember(type: .apple)
        }

        return btn
    }()
    
    private lazy var loginButtonStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        
        indicatorView.style = .large
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        indicatorView.color = .gray0
        
        return indicatorView
    }()
    
    private lazy var blurEffectView = BlurEffectView()
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
}

extension LoginViewController: LoginViewProtocol {
    // MARK: Set up func
    func setupLayout() {
        [
            naverButton,
            kakaoButton,
            googleButton,
            appleButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            loginButtonStackView.addArrangedSubview($0)
        }
        
        [
            titleImageView,
            berryMapImageView,
            loginButtonStackView,
            blurEffectView,
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            berryMapImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            berryMapImageView.bottomAnchor.constraint(equalTo: loginButtonStackView.topAnchor, constant: -45),
            
            loginButtonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 26.5),
            loginButtonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -26.5),
            loginButtonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    func setupAttribute() {
        view.backgroundColor = .gray7
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        applyGradientToLoginView()
    }
    
    // MARK: UI Interactions
    @objc private func tapAppleLogin() {
        presenter.clickedAppleLogin()
    }
    
    func switchIsLoading(with loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.indicatorView.isHidden = !loading
            self?.blurEffectView.isHidden = !loading
        }
    }
    
    // MARK: Push Intercations
    func pushTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                AppController.shared.show(in: window)
            }
        }
    }
    
    // TODO: 코드 수정 필요
    func pushRegistrationView() {
        let viewController = FirstRegistrationViewController()
        
        let presenter = FirstRegistrationPresenter(viewController: viewController)
        
        viewController.presenter = presenter
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushRegistrationWhenAppleLogin(_ userModel: AVIROAppleUserSignUpDTO) {
        DispatchQueue.main.async { [weak self] in
            let viewController = FirstRegistrationViewController()
            
            let presenter = FirstRegistrationPresenter(
                viewController: viewController,
                appleUserSignUpModel: userModel
            )
            
            viewController.presenter = presenter

            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: Alert Interactions
    func afterLogoutAndMakeToastButton() {
        showSimpleToast(with: Text.logoutToast.rawValue)
    }
    
    func afterWithdrawalUserShowAlert() {
        let alertTitle = Text.withdrawalTitle.rawValue
        let alertMessage = Text.withdrawalMessage.rawValue
        
        showAlert(title: alertTitle, message: alertMessage)
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
