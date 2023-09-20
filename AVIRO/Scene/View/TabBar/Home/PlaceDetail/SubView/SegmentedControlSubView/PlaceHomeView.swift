//
//  PlaceHomeView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/11.
//

import UIKit

// TODO: SegmentedControl의 메뉴뷰를 그대로 가져오는 방법은 없을까?
final class PlaceHomeView: UIView {
    private lazy var placeInfoView = PlaceInfoView()
    private lazy var placeMenuView = PlaceMenuView()
    private lazy var placeReviewWriteView = PlaceReviewWriteView()
    private lazy var placeReviewsView = PlaceReviewsView()
    
    private var viewHeightConstraint: NSLayoutConstraint?

    // Place Info 관련 클로저
    var afterPhoneButtonTappedWhenNoData: (() -> Void)?
    var afterTimePlusButtonTapped: (() -> Void)?
    var afterTimeTableShowButtonTapped: (() -> Void)?
    var afterHomePageButtonTapped: ((String) -> Void)?
    var afterEditInfoButtonTapped: (() -> Void)?

    // menu 관련 클로저
    var showMoreMenu: (() -> Void)?
    var editMenu: (() -> Void)?
    
    // review 관련 클로저
    var showMoreReviews: (() -> Void)?
    var showMoreReviewsAndWriteComment: (() -> Void)?
    var reportReview: ((AVIROReportCommentModel) -> Void)?
    var editMyReview: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeLayout()
        handleClosure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        initPlaceHomeView()
    }
    
    private func makeLayout() {
        self.backgroundColor = .gray6
        // 300 + 200 + 250 + 200
        viewHeightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        viewHeightConstraint?.isActive = true
        
        [
            placeInfoView,
            placeMenuView,
            placeReviewWriteView,
            placeReviewsView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeInfoView.topAnchor.constraint(equalTo: self.topAnchor),
            placeInfoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeInfoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeMenuView.topAnchor.constraint(equalTo: placeInfoView.bottomAnchor, constant: 15),
            placeMenuView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeMenuView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeReviewWriteView.topAnchor.constraint(equalTo: placeMenuView.bottomAnchor, constant: 15),
            placeReviewWriteView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeReviewWriteView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeReviewsView.topAnchor.constraint(equalTo: placeReviewWriteView.bottomAnchor, constant: 15),
            placeReviewsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeReviewsView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func initPlaceHomeView() {
        let infoHeight = placeInfoView.frame.height
        let menuHeight = placeMenuView.frame.height
        let reviewWriteHeight = placeReviewWriteView.frame.height
        let reviewsHeight = placeReviewsView.frame.height
        
        // 15 15 15
        let inset: CGFloat = 45
        
        let totalHeight = infoHeight + menuHeight + reviewWriteHeight + reviewsHeight + inset
        viewHeightConstraint?.constant = totalHeight

    }
    
    func dataBinding(infoModel: PlaceInfoData?,
                     menuModel: PlaceMenuData?,
                     reviewsModel: AVIROReviewsModelArrayDTO?
    ) {
        placeInfoView.dataBindingWhenInHomeView(infoModel)
        placeMenuView.dataBindingWhenInHomeView(menuModel)
        placeReviewsView.dataBindingWhenInHomeView(reviewsModel)
    }
    
    func refreshMenuData(_ menuModel: PlaceMenuData?) {
        placeMenuView.dataBindingWhenInHomeView(menuModel)
    }
    
    func updateReview(_ postModel: AVIROEnrollCommentDTO) {
        placeReviewsView.afterUpdateReviewAndUpdateInHomeView(postModel)
    }
    
    func whenAfterEditReview(_ model: AVIROEditCommentDTO) {
        placeReviewsView.afterEditReviewAndUpdateInHomeView(model)
    }
    
    func deleteMyReview(_ commentId: String) {
        placeReviewsView.deleteMyReview(commentId)
    }
    
    // MARK: 클로저 처리
    private func handleClosure() {
        // Place Info View
        placeInfoView.afterPhoneButtonTappedWhenNoData = { [weak self] in
            self?.afterPhoneButtonTappedWhenNoData?()
        }
        
        placeInfoView.afterTimePlusButtonTapped = { [weak self] in
            self?.afterTimePlusButtonTapped?()
        }
        
        placeInfoView.afterTimeTableShowButtonTapped = { [weak self] in
            self?.afterTimeTableShowButtonTapped?()
        }
        
        placeInfoView.afterHomePageButtonTapped = { [weak self] url in
            self?.afterHomePageButtonTapped?(url)
        }
        
        placeInfoView.afterEditInfoButtonTapped = { [weak self] in
            self?.afterEditInfoButtonTapped?()
        }
        
        // Place Menu View
        placeMenuView.editMenuButton = { [weak self] in
            self?.editMenu?()
        }
        
        placeMenuView.showMoreMenu = { [weak self] in
            self?.showMoreMenu?()
        }
        
        // Place Review Write View
        placeReviewWriteView.whenWriteReviewButtonTapped = { [weak self] in
            self?.showMoreReviewsAndWriteComment?()
        }
        
        // Place Reviews View
        placeReviewsView.whenTappedShowMoreButton = { [weak self] in
            self?.showMoreReviews?()
        }
        
        placeReviewsView.whenReportReview = { [weak self] reportCommentModel in
            self?.reportReview?(reportCommentModel)
        }
        
        placeReviewsView.whenBeforeEditMyReview = { [weak self] commentId in
            self?.editMyReview?(commentId)
        }
    }
}
