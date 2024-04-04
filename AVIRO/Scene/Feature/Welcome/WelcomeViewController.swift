//
//  WelcomeViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/11.
//
//
import UIKit

// MARK: - 기능 추가시 MVVM으로 Refectoring

final class WelcomeViewController: UIViewController {
    var tabBarDelegate: TabBarFromSubVCDelegate?
    
    private var amplitude: AmplitudeProtocol?
    
    private var images: [URL] = [] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            WelcomeCollectionViewCell.self,
            forCellWithReuseIdentifier: WelcomeCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private lazy var failureLabel: UILabel = {
        let lbl = UILabel()
       
        lbl.text = "이미지 로딩에 실패했습니다"
        lbl.numberOfLines = 2
        lbl.textColor = .gray2
        lbl.font = .pretendard(size: 16, weight: .semibold)
        lbl.isHidden = true
        
        return lbl
    }()
    
    private lazy var noShowButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .clear
        btn.setTitle("오늘 하루 보지 않기", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.titleLabel?.font = .pretendard(size: 18, weight: .medium)
        btn.titleEdgeInsets = .init(top: 0, left: 0, bottom: -10, right: 0)
        
        btn.addTarget(
            self,
            action: #selector(noShowButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return btn
    }()
    
    private lazy var separatorLabel: UILabel = {
        let lbl = UILabel()
       
        lbl.backgroundColor = .clear
        lbl.text = "|"
        lbl.font = .pretendard(size: 18, weight: .medium)
        lbl.textColor = .gray7
        
        return lbl
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .clear
        btn.setTitle("닫기", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.titleLabel?.font = .pretendard(size: 18, weight: .medium)
        btn.titleEdgeInsets = .init(top: 0, left: 0, bottom: -10, right: 0)

        btn.addTarget(
            self,
            action: #selector(closeButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return btn
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let view = UIStackView()
       
        view.backgroundColor = .clear
        view.distribution = .fillProportionally
        view.alignment = .bottom
        view.axis = .horizontal
        view.spacing = 16
        
        return view
    }()
    
    static func create() -> WelcomeViewController {
        let vc = WelcomeViewController()
                
        return vc
    }
    
    var didTappedNoShowButton: (() -> Void)?
    var didTappedCloseButton: (() -> Void)?
    var didTappedCheckButton: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
    }
    
    private func setupLayout() {
        [
            noShowButton,
            separatorLabel,
            closeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomStackView.addArrangedSubview($0)
        }
        
        [
            imageCollectionView,
            bottomStackView,
            failureLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 380),
            
            bottomStackView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30.5),
            bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30.5),
            bottomStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            failureLabel.centerXAnchor.constraint(equalTo: imageCollectionView.centerXAnchor),
            failureLabel.centerYAnchor.constraint(equalTo: imageCollectionView.centerYAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .clear
    }
    
    func loadWellcomeImage(completionHandler: @escaping () -> Void) {
        AVIROAPI.manager.loadWellcomeImagesURL { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let imageURL = data.data?.imageUrl {
                        guard let url = URL(string: imageURL) else { return }
                        let urlArray = [url]
                        self.urlLoadFail(with: false)
                        
                        self.images = urlArray
                        completionHandler()
                    }
                case .failure(let _):
                    self.urlLoadFail(with: true)
                    completionHandler()
                }
            }
        }
    }
    
    private func urlLoadFail(with isFail: Bool) {
        failureLabel.isHidden = !isFail
    }
    
    @objc private func noShowButtonTapped(_ sender: UIButton) {
        didTappedNoShowButton?()
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        didTappedCloseButton?()
    }
}

extension WelcomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 280, height: 380)
    }
}

extension WelcomeViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return images.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView, 
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WelcomeCollectionViewCell.identifier,
            for: indexPath
        ) as? WelcomeCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(with: images[indexPath.row])
        
        cell.didTappedCheckButton = { [weak self] in
            self?.didTappedCheckButton?()
        }
        
        return cell
    }
}
