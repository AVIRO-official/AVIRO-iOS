//
//  ChallengeViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/18.
//

import UIKit

import RxSwift
import RxCocoa

final class ChallengeViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var challengeTitleView: ChallengeTitleView = {
        let view = ChallengeTitleView()
        
        return view
    }()
    
    private lazy var challengeLevelView: ChallengeLevelView = {
        let view = ChallengeLevelView()
        
        return view
    }()
    
    private lazy var myInfoView: MyInfoView2 = {
        let view = MyInfoView2()
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
        dataBinding()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
        
        [
            challengeTitleView,
            challengeLevelView,
            myInfoView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            challengeTitleView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 16
            ),
            challengeTitleView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            challengeTitleView.heightAnchor.constraint(
                equalToConstant: 107
            ),
            
            challengeLevelView.topAnchor.constraint(
                equalTo: challengeTitleView.bottomAnchor,
                constant: 16
            ),
            challengeLevelView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            challengeLevelView.heightAnchor.constraint(
                equalToConstant: 341
            ),
            
            myInfoView.topAnchor.constraint(
                equalTo: challengeLevelView.bottomAnchor,
                constant: 20
            ),
            myInfoView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            myInfoView.heightAnchor.constraint(equalToConstant: 81),
            myInfoView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            )
        ])
    }
    
    private func setupAttribute() {
        navigationItem.title = "챌린지"
        navigationController?.navigationBar.isHidden = false
        
        let rightBarButton = UIBarButtonItem(
            image: UIImage.user2,
            style: .done,
            target: nil,
            action: nil
        )
        rightBarButton.tintColor = .gray1
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func dataBinding() {
        // TODO: ViewModel 생성 후 변경 예정
        myInfoView.updateMyPlace("2")
        myInfoView.updateMyReview("3")
        myInfoView.updateMyStar("4")
    }
}
