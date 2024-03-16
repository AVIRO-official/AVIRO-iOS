//
//  WellcomeViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/11.
//
//
import UIKit

// MARK: - 기능 추가시 MVVM으로 Refectoring

final class WellcomeViewController: UIViewController {
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
            WellcomeCollectionViewCell.self,
            forCellWithReuseIdentifier: WellcomeCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private lazy var noShowButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .clear
        btn.setTitle("24시간 보지 않기", for: .normal)
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
    
    static func create() -> WellcomeViewController {
        let vc = WellcomeViewController()
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupLayout()
        
        dataBinding()
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
            bottomStackView
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
            bottomStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setupAttribute() {
        self.view.backgroundColor = .clear
    }
    
    private func dataBinding() {
        AVIROAPI.manager.loadWellcomeImagesURL { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let imageURL = data.data?.imageUrl {
                        guard let url = URL(string: imageURL) else { return }
                        
                        let urlArray = [url]
                        self.images = urlArray
                    }
                case .failure(let error):
                    break
                }
            }
        }
    }
    
    @objc private func noShowButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        
    }
}

extension WellcomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 280, height: 380)
    }
}

extension WellcomeViewController: UICollectionViewDataSource {
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
            withReuseIdentifier: WellcomeCollectionViewCell.identifier,
            for: indexPath
        ) as? WellcomeCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(with: images[indexPath.row])
        
        return cell
    }
}
