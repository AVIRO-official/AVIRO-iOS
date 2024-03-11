////
////  FirstPopupViewController.swift
////  AVIRO
////
////  Created by 전성훈 on 2024/03/11.
////
//
//import UIKit
//
//final class FirstPopupViewController: UIViewController {
//    private lazy var imageCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.alwaysBounceHorizontal = false
//        collectionView.backgroundColor = .clear
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(
//            FirstPopupCollectionViewCell.self,
//            forCellWithReuseIdentifier: FirstPopupCollectionViewCell.identifier
//        )
//        
//        return collectionView
//    }()
//    
//    private lazy var checkButton: UIButton = {
//        let btn = UIButton()
//        
//        return btn
//    }()
//    
////    private lazy var noMoreShowUntilTomorrowButton:
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    private func setupLayout() {
//        
//    }
//    
//    private func setupAttribute() {
//        
//    }
//}
//
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
