//
//  SettingCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/08.
//

import UIKit

final class SettingCell: UITableViewCell {
    static let identifier = "SettingCell"
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(.gray0, for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .medium)
        button.addTarget(self,
                         action: #selector(buttonTapped),
                         for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var pushButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(named: "PushView"), for: .normal)
        button.addTarget(self,
                         action: #selector(buttonTapped),
                         for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()

        label.textColor = .gray2
        label.font = .pretendard(size: 15, weight: .regular)
        
        return label
    }()
    
    private lazy var socialLogo: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private lazy var socialLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 15, weight: .regular)
        
        return lbl
    }()
    
    private var settingValue: SettingsRow!
    
    var tappedAfterSettingValue: ((SettingsRow) -> Void)?
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout() {
        [
            settingButton,
            pushButton,
            versionLabel,
            socialLogo,
            socialLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
                
        NSLayoutConstraint.activate([
            settingButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            settingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            pushButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            pushButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            versionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            socialLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            socialLogo.trailingAnchor.constraint(equalTo: socialLabel.leadingAnchor, constant: -3),
            socialLogo.widthAnchor.constraint(equalToConstant: 24),
            socialLogo.heightAnchor.constraint(equalToConstant: 24),
            
            socialLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            socialLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
        
        pushButton.isHidden = true
        versionLabel.isHidden = true
        socialLogo.isHidden = true
        socialLabel.isHidden = true
    }
    
    private func setupAttribute() {
        self.backgroundColor = .gray7
    }
    
    func dataBinding(_ settingsRow: SettingsRow) {
        if settingsRow == .versionInfo {
            versionLabel.isHidden = false
            loadVersion()
        }
        
        if settingsRow == .logout {
            settingButton.setTitleColor(.red, for: .normal)
            socialLogo.isHidden = false
            socialLabel.isHidden = false
            
            switch UserDefaults.standard.string(forKey: UDKey.loginType.rawValue) {
            case "apple":
                socialLabel.text = "Apple 계정"
                socialLogo.image = .appleLogo
            case "google":
                socialLabel.text = "Google 계정"
                socialLogo.image = .googleLogo
            case "kakao":
                socialLabel.text = "Kakao 계정"
                socialLogo.image = .kakaoLogo
            case "naver":
                socialLabel.text = "Naver 계정"
                socialLogo.image = .naverLogo
            default:
                break
            }
        }
        
        self.settingValue = settingsRow
        settingButton.setTitle(settingsRow.rawValue, for: .normal)
    }
    
    @objc private func buttonTapped() {
        tappedAfterSettingValue?(settingValue)
    }
    
    private func loadVersion() {
        SystemUtility().latestVersion { [weak self] latestVersion in
            let latestVersion = latestVersion ?? "0.0.0"
            let currentVersion = SystemUtility.appVersion ?? "0.0.0"
            
            self?.versionLabel.text = "현재" + currentVersion + " / " + "최신 " + latestVersion
        }
    }
}
