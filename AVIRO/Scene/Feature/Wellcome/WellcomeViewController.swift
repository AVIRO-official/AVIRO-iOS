////
////  WellcomeViewController.swift
////  AVIRO
////
////  Created by 전성훈 on 2024/03/11.
////
//
import UIKit

// MARK: - 기능 추가시 MVVM으로 Refectoring

final class WellcomeViewController: UIViewController {
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = .clear
//        collectionView.dataSource = self
//        collectionView.delegate = self
        collectionView.register(
            WellcomeCollectionViewCell.self,
            forCellWithReuseIdentifier: WellcomeCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private lazy var noShowButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .clear
        btn.setTitle(<#T##String?#>, for: <#T##UIControl.State#>)
        
        return btn
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        
        btn.backgroundColor = .clear
        btn.setTitle("닫기", for: .normal)
        btn.setTitleColor(.gray7, for: .normal)
        btn.addTarget(
            self,
            action: #selector(closeButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupAttribute() {
        
    }
    
    @objc private func noShowButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        
    }
}

//extension FirstPopupViewController: UICollectionViewDelegateFlowLayout {
//    
//}
//
//extension FirstPopupViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//    }
//    
//    
//}
