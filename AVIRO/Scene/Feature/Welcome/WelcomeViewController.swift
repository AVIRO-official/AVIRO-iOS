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
    
    private var welcomePopups : [WelcomePopup] = [] {
        didSet {
            imageCollectionView.reloadData()
            viewPageControl.numberOfPages = welcomePopups.count
        }
    }
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        collectionView.register(
            WelcomeCollectionViewCell.self,
            forCellWithReuseIdentifier: WelcomeCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private lazy var viewPageControl: UIPageControl = {
        let pageControl = UIPageControl()
       
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .main
        pageControl.pageIndicatorTintColor = .gray5
        
        pageControl.addTarget(
            self, 
            action: #selector(pageControlTapped(_:)),
            for: .valueChanged
        )
        
        return pageControl
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
        btn.titleEdgeInsets = .init(
            top: 0,
            left: 0,
            bottom: -10,
            right: 0
        )
        
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
        btn.titleEdgeInsets = .init(
            top: 0,
            left: 0,
            bottom: -10,
            right: 0
        )
        
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
            failureLabel,
            viewPageControl
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 380),
            
            viewPageControl.topAnchor.constraint(
                equalTo: imageCollectionView.bottomAnchor,
                constant: 6
            ),
            viewPageControl.centerXAnchor.constraint(
                equalTo: imageCollectionView.centerXAnchor
            ),
            
            bottomStackView.topAnchor.constraint(equalTo: viewPageControl.bottomAnchor, constant: 12),
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
    
    func loadWelcomeImage(completionHandler: @escaping () -> Void) {
        AVIROAPI.manager.loadWelcomePopups { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let orderedData = data.data?
                        .sorted(by: { $0.order < $1.order })
                        .map({ $0.toDomain() }) {
                        self.urlLoadFail(with: false)
                        completionHandler()
                        
                        self.welcomePopups = orderedData
                        
                        completionHandler()
                    } else {
                        self.urlLoadFail(with: true)
                        completionHandler()
                    }
                case .failure(let _):
                    self.urlLoadFail(with: true)
                    completionHandler()
                }
            }
        }
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        
        let indexPath = IndexPath(item: currentPage, section: 0)

        imageCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
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
        return CGSize(width: 270, height: 380)
    }
}

extension WelcomeViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return welcomePopups.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WelcomeCollectionViewCell.identifier,
            for: indexPath
        ) as? WelcomeCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(with: welcomePopups[indexPath.row])
        
        cell.didTappedCheckButton = { [weak self] in
            self?.didTappedCheckButton?()
        }
        
        return cell
    }
}
