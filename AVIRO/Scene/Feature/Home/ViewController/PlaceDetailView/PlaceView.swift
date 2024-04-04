//
//  PlaceInfoView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/10.
//

import UIKit

final class PlaceView: UIView {
    private lazy var summaryView = PlaceSummaryView()
    
    private lazy var segmentedControlView = PlaceSegmentedControlView()
    
    var placeViewStated: PlaceViewState = PlaceViewState.noShow {
        didSet {
            switch placeViewStated {
            case .popup:
                whenViewPopUp()
            case .slideup:
                whenViewSlideUp()
            case .full:
                whenViewFullUp()
            default:
                break
            }
            self.layoutIfNeeded()
        }
    }
    
    var isLoadingTopView: Bool = true {
        didSet {
            if isLoadingTopView {
                summaryView.isLoadingTopView = isLoadingTopView
                summaryView.isUserInteractionEnabled = false
            } else {
                summaryView.isLoadingTopView = isLoadingTopView
                summaryView.isUserInteractionEnabled = true
            }
        }
    }
    
    var isLoadingDetail: Bool = true {
        didSet {
            if isLoadingDetail {
                segmentedControlView.isLoading = isLoadingDetail
            } else {
                segmentedControlView.isLoading = isLoadingDetail
            }
        }
    }
    
    private var placeId = ""
    
    // MARK: Top View
    var whenFullBack: (() -> Void)?
    var whenShareTapped: (([String]) -> Void)?
    var whenTopViewStarTapped: ((Bool) -> Void)?
    
    // MARK: SegmentedControl
    var afterPhoneButtonTappedWhenNoData: (() -> Void)?
    var afterTimePlusButtonTapped: (() -> Void)?
    var afterTimeTableShowButtonTapped: (() -> Void)?
    var afterHomePageButtonTapped: ((String) -> Void)?
    var afterEditInfoButtonTapped: (() -> Void)?
    
    var editMenu: (() -> Void)?
    
//    var whenUploadReview: ((AVIROEnrollReviewDTO) -> Void)?
    var whenAfterEditReview: ((AVIROEditReviewDTO) -> Void)?
    
    var reportReview: ((AVIROReportReviewModel) -> Void)?
    var whenBeforeEditMyReview: ((String, String) -> Void)?
    
    var pushReviewWriteView: (() -> Void)? 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeLayout()
        handleClosure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeLayout() {
        self.backgroundColor = .clear
        
        [
            summaryView,
            segmentedControlView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            summaryView.topAnchor.constraint(equalTo: self.topAnchor),
            summaryView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            segmentedControlView.topAnchor.constraint(equalTo: summaryView.bottomAnchor),
            segmentedControlView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControlView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func setSegmentedControlIndex(with index: Int) {
        segmentedControlView.setSegmentedControlIndex(with: index)
    }
    
    func topViewHeight() -> CGFloat {
        return summaryView.frame.height
    }
    
    func summaryDataBinding(placeModel: PlaceTopModel,
                            placeId: String,
                            isStar: Bool
    ) {
        self.placeId = placeId
        
        summaryView.dataBinding(placeModel, isStar)
        isLoadingTopView = false
    }
    
    func menuModelBinding(menuModel: AVIROPlaceMenus?) {
        segmentedControlView.refreshMenuData(menuModel)
    }
    
    func updateMapPlace(_ mapPlace: VeganType) {
        summaryView.updateMapPlace(mapPlace)
    }
    
    func updateReview(with model: AVIROEnrollReviewDTO) {
        segmentedControlView.updateReview(with: model)
    }
  
    func deleteMyReview(_ commentId: String) {
        segmentedControlView.deleteMyReview(commentId)
    }
    
    func allDataBinding(infoModel: AVIROPlaceInfo?,
                        menuModel: AVIROPlaceMenus?,
                        reviewsModel: AVIROReviewsArray?
    ) {
        segmentedControlView.allDataBinding(
            placeId: self.placeId,
            infoModel: infoModel,
            menuModel: menuModel,
            reviewsModel: reviewsModel
        )
        isLoadingDetail = false
    }
    
    // TODO: After Edit My Review 수정
    func editMyReview(with model: AVIROEnrollReviewDTO) {
        segmentedControlView.editMyReview(with: model)
    }
    
    private func whenViewPopUp() {
        summaryView.placeViewStated = .popup
        segmentedControlView.whenViewPopup()
    }
    
    private func whenViewSlideUp() {
        summaryView.placeViewStated = .slideup
        segmentedControlView.scrollViewIsUserIneraction(false)
        
    }
    
    private func whenViewFullUp() {
        summaryView.placeViewStated = .full
        segmentedControlView.scrollViewIsUserIneraction(true)
    }
    
    private func handleClosure() {
        // MARK: Top View
        summaryView.whenFullBackButtonTapped = { [weak self] in
            self?.whenFullBack?()
        }
        
        summaryView.whenShareButtonTapped = { [weak self] shareObject in
            self?.whenShareTapped?(shareObject)
        }
        
        summaryView.whenStarButtonTapped = { [weak self] selected in
            self?.whenTopViewStarTapped?(selected)
        }
        
        // MARK: Segmented
        // place info
        segmentedControlView.afterPhoneButtonTappedWhenNoData = { [weak self] in
            self?.afterPhoneButtonTappedWhenNoData?()
        }
        
        segmentedControlView.afterTimePlusButtonTapped = { [weak self] in
            self?.afterTimePlusButtonTapped?()
        }
        
        segmentedControlView.afterTimeTableShowButtonTapped = { [weak self] in
            self?.afterTimeTableShowButtonTapped?()
        }
        
        segmentedControlView.afterHomePageButtonTapped = { [weak self] url in
            self?.afterHomePageButtonTapped?(url)
        }
        
        segmentedControlView.afterEditInfoButtonTapped = { [weak self] in
            self?.afterEditInfoButtonTapped?()
        }
        
        // place menu
        segmentedControlView.editMenu = { [weak self] in
            self?.editMenu?()
        }
        
//        // place review
//        segmentedControlView.whenUploadReview = { [weak self] postReviewModel in
//            self?.whenUploadReview?(postReviewModel)
//        }
        
        segmentedControlView.whenAfterEditReview = { [weak self] postEditReviewModel in
            self?.whenAfterEditReview?(postEditReviewModel)
        }
        
        segmentedControlView.updateReviewsCount = { [weak self] reviewsCount in
            self?.summaryView.updateReviewsCount(reviewsCount)
        }
        
        segmentedControlView.reportReview = { [weak self] reportCommentModel in
            self?.reportReview?(reportCommentModel)
        }
        
        segmentedControlView.whenBeforeEditMyReview = { [weak self] (commentId, content) in
            self?.whenBeforeEditMyReview?(commentId, content)
        }
        
        segmentedControlView.pushReviewWriteView = { [weak self] in
            self?.pushReviewWriteView?()
        }
    }
    
//    func keyboardWillShow(notification: NSNotification, height: CGFloat) {
//        segmentedControlView.keyboardWillShow(notification: notification, height: height)
//    }
//    
//    func keyboardWillHide() {
//        segmentedControlView.keyboardWillHide()
//    }

}
