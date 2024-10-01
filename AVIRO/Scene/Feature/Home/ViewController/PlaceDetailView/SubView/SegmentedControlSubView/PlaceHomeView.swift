//
//  PlaceHomeView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/11.
//

import UIKit

final class PlaceHomeView: UIView {
    
    private lazy var placeInfoView = PlaceInfoView()
    lazy var placeMenuView = PlaceMenuView()
    private lazy var placeReviewWriteView = PlaceReviewWriteView()
    lazy var placeReviewsView = PlaceReviewsView()
    private lazy var placeDeleteRequestView = PlaceDeleteRequestView()
    
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
    var reportReview: ((AVIROReportReviewModel) -> Void)?
    var whenBeforeEditMyReview: ((String, String) -> Void)?
    
    // delete 클로저
    var deleteRequestButtonTapped: (() -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeLayout()
        handleClosure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeLayout()
        handleClosure()
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
            placeReviewWriteView,
            placeMenuView,
            placeReviewsView,
            placeDeleteRequestView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeInfoView.topAnchor.constraint(equalTo: self.topAnchor),
            placeInfoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeInfoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeReviewWriteView.topAnchor.constraint(equalTo: placeInfoView.bottomAnchor, constant: 15),
            placeReviewWriteView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeReviewWriteView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeMenuView.topAnchor.constraint(equalTo: placeReviewWriteView.bottomAnchor, constant: 15),
            placeMenuView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeMenuView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeReviewsView.topAnchor.constraint(equalTo: placeMenuView.bottomAnchor, constant: 15),
            placeReviewsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeReviewsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            placeDeleteRequestView.topAnchor.constraint(equalTo: placeReviewsView.bottomAnchor, constant: 15),
            placeDeleteRequestView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeDeleteRequestView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func initPlaceHomeView() {
        let infoHeight = placeInfoView.frame.height
        let menuHeight = placeMenuView.frame.height
        let reviewWriteHeight = placeReviewWriteView.frame.height
        let reviewsHeight = placeReviewsView.frame.height
        let deleteRequestViewHeight = placeDeleteRequestView.frame.height

        // 15 15 15 15
        let inset: CGFloat = 60
        
        let totalHeight = infoHeight + menuHeight + reviewWriteHeight + reviewsHeight + inset + deleteRequestViewHeight
        viewHeightConstraint?.constant = totalHeight

    }
    
    func dataBinding(infoModel: AVIROPlaceInfo?,
                     menuModel: AVIROPlaceMenus?,
                     reviewsModel: AVIROReviewsArray?
    ) {
        placeInfoView.dataBindingWhenInHomeView(infoModel)
        placeMenuView.dataBindingWhenInHomeView(menuModel)
        placeReviewsView.dataBindingWhenInHomeView(reviewsModel)
    }
        
    func refreshMenuData(_ menuModel: AVIROPlaceMenus?) {
        placeMenuView.dataBindingWhenInHomeView(menuModel)
    }
    
    func updateReview(_ postModel: AVIROEnrollReviewDTO) {
        placeReviewsView.afterUpdateReviewAndUpdateInHomeView(postModel)
    }
    
    func whenAfterEditReview(_ model: AVIROEditReviewDTO) {
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
        
        placeReviewsView.whenBeforeEditMyReview = { [weak self] (commentId, content) in
            self?.whenBeforeEditMyReview?(commentId, content)
        }
        
        // Place Delete Request View
        placeDeleteRequestView.deleteRequestButtonTapped = { [weak self] in
            self?.deleteRequestButtonTapped?()
        }
    }
}
