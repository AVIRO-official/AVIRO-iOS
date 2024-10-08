//
//  PlaceSegmentedControlView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/11.
//

import UIKit

private enum Segmented: String {
    case home = "홈"
    case menu = "메뉴"
    case reviews = "후기 (0)"
}

final class PlaceSegmentedControlView: UIView {
    
    private lazy var items = [Segmented.home.rawValue, Segmented.menu.rawValue, Segmented.reviews.rawValue]
    
    private lazy var segmentedControl = UnderlineSegmentedControl(items: items)
    
    private lazy var homeView = PlaceHomeView()
    private lazy var menuView = PlaceMenuView()
    private lazy var reviewView = PlaceReviewsView()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        
        indicatorView.color = .gray1
        indicatorView.style = UIActivityIndicatorView.Style.medium
        indicatorView.startAnimating()
        
        return indicatorView
    }()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var leftSwipeGesture = UISwipeGestureRecognizer()
    private lazy var rightSwipteGesture = UISwipeGestureRecognizer()
    
    private var homeBottomConstraint: NSLayoutConstraint?
    
    private var afterInitViewConstrait = false
    
    private var placeId = ""
    
    private var reviewsCount = 0 {
        didSet {
            // segmented에 있는 count, top view에 있는 count 최신화
            segmentedControlLabelChange(reviewsCount)
            updateReviewsCount?(reviewsCount)
        }
    }
    
    var isLoading = true {
        didSet {
            if isLoading {
                whenIsLoading()
            } else {
                whenIsEndLoading()
            }
        }
    }
    
    var isScrollUntilMenu = false
    var isScrollUntilReview = false
    var isTabbedMenu = false
    var isTabbedReview = false
    
    // placeInfo
    var afterPhoneButtonTappedWhenNoData: (() -> Void)?
    var afterTimePlusButtonTapped: (() -> Void)?
    var afterTimeTableShowButtonTapped: (() -> Void)?
    var afterHomePageButtonTapped: ((String) -> Void)?
    var afterEditInfoButtonTapped: (() -> Void)?
    
    // menu
    var editMenu: (() -> Void)?
    
    // review
    var whenUploadReview: ((AVIROEnrollReviewDTO) -> Void)?
    var whenAfterEditReview: ((AVIROEditReviewDTO) -> Void)?
    var updateReviewsCount: ((Int) -> Void)?
    var reportReview: ((AVIROReportReviewModel) -> Void)?
    var whenBeforeEditMyReview: ((String, String) -> Void)?
    
    var pushReviewWriteView: ((ReviewUploadPagePathType) -> Void)?
    
    // delete request
    var deleteRequestButtonTapped: (() -> Void)?
    
    var scrolledMenu: (() -> Void)?
    var scrolledReview: (() -> Void)?
    var tabbedMenu: (() -> Void)?
    var tabbedReview: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeLayout()
        makeAttribute()
        makeGesture()
        handleClosure()
        
        scrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeLayout() {
        
        [
            segmentedControl,
            scrollView,
            menuView,
            reviewView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 12),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            segmentedControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            menuView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            menuView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            menuView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            reviewView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            reviewView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            reviewView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            reviewView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        makeLayoutInScrollView()
        makeLayoutIndicatorView()
    }
    
    private func makeLayoutInScrollView() {
        [
            homeView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            homeView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            homeView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }
    
    private func makeLayoutIndicatorView() {
        [
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 32),
            indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    private func makeAttribute() {
        self.backgroundColor = .gray7
        scrollView.backgroundColor = .gray6
        
        segmentedControl.setAttributedTitle()
        segmentedControl.addTarget(self, action: #selector(segmentedChanged(segment:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func makeGesture() {
        self.addGestureRecognizer(leftSwipeGesture)
        self.addGestureRecognizer(rightSwipteGesture)
        
        leftSwipeGesture.direction = .left
        rightSwipteGesture.direction = .right
        
        leftSwipeGesture.addTarget(self, action: #selector(swipeGestureActived(_:)))
        rightSwipteGesture.addTarget(self, action: #selector(swipeGestureActived(_:)))
    }
    
    @objc private func swipeGestureActived(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right && segmentedControl.selectedSegmentIndex != 0 {
            segmentedControl.selectedSegmentIndex -= 1
        } else if gesture.direction == .left && segmentedControl.selectedSegmentIndex != 2 {
            segmentedControl.selectedSegmentIndex += 1
        }
        
        whenActiveSegmentedChanged()
    }
    
    func allDataBinding(placeId: String,
                        infoModel: AVIROPlaceInfo?,
                        menuModel: AVIROPlaceMenus?,
                        reviewsModel: AVIROReviewsArray?
    ) {
        self.placeId = placeId
        
        homeView.dataBinding(infoModel: infoModel,
                             menuModel: menuModel,
                             reviewsModel: reviewsModel
        )
        
        menuView.dataBinding(menuModel)
        
        reviewView.dataBinding(placeId: placeId,
                               reviewsModel: reviewsModel
        )
        
        guard let reviewsCount = reviewsModel?.commentArray.count else { return }
        
        self.reviewsCount = reviewsCount
    }
    
    private func segmentedControlLabelChange(_ reviews: Int) {
        let reviews = "후기 (\(reviews))"
        
        segmentedControl.setTitle(reviews, forSegmentAt: 2)
    }
    
    private func whenIsLoading() {
        homeView.isHidden = true
        menuView.isHidden = true
        reviewView.isHidden = true
        segmentedControl.isUserInteractionEnabled = false
        indicatorView.isHidden = false
    }
    
    private func whenIsEndLoading() {
        homeView.isHidden = false
        segmentedControl.isUserInteractionEnabled = true
        indicatorView.isHidden = true
    }
    
    @objc private func segmentedChanged(segment: UISegmentedControl) {
        whenActiveSegmentedChanged()
    }
    
    private func whenActiveSegmentedChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            activeHomeView()
        case 1:
            activeMenuView()
        case 2:
            activeReviewView()
        default:
            break
        }
    }
    
    func setSegmentedControlIndex(with index: Int) {
        segmentedControl.selectedSegmentIndex = index
        
        switch index {
        case 0: activeHomeView()
        case 1: activeMenuView()
        case 2: activeReviewView()
        default: break
        }
    }
    
    /// API 호출 후 선택되면 딜레이 보여서 따로 뺌
    func whenViewPopup() {
        segmentedControl.selectedSegmentIndex = 0
        
        scrollViewSetOffset()
    }
    
    private func activeHomeView() {
        scrollViewSetOffset()
        
        menuView.isHidden = true
        reviewView.isHidden = true
        
        homeView.isHidden = false
    }
    
    private func activeMenuView() {
        homeView.isHidden = true
        reviewView.isHidden = true
        
        menuView.isHidden = false
        
        if !isTabbedMenu {
            isTabbedMenu.toggle()
            tabbedMenu?()
        }
    }
    
    private func activeReviewView() {
        menuView.isHidden = true
        homeView.isHidden = true
        
        reviewView.isHidden = false
        
        if !isTabbedReview {
            isTabbedReview.toggle()
            tabbedReview?()
        }
    }
    
    private func scrollViewSetOffset(_ x: Double = 0.0,
                                     _ y: Double = 0.0,
                                     _ animated: Bool = false
    ) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
    }
    
    func scrollViewIsUserIneraction(_ enabled: Bool) {
        scrollView.isUserInteractionEnabled = enabled
        menuView.isUserInteractionEnabled = enabled
        reviewView.isUserInteractionEnabled = enabled
    }
    
    func refreshMenuData(_ menuModel: AVIROPlaceMenus?) {
        homeView.refreshMenuData(menuModel)
        menuView.dataBinding(menuModel)
    }
    
    func updateReview(with model: AVIROEnrollReviewDTO) {
        reviewView.updateReviewArray(with: model)
    }
    
    func editMyReview(with model: AVIROEnrollReviewDTO) {
        //        if segmentedControl.selectedSegmentIndex == 0 {
        //            self.segmentedControl.selectedSegmentIndex = 2
        //            self.activeReviewView()
        //        }
        reviewView.editMyReview(with: model)
    }
    
    func deleteMyReview(_ commentId: String) {
        self.reviewsCount -= 1
        
        homeView.deleteMyReview(commentId)
        reviewView.deleteMyReview(commentId)
    }
    
    // MARK: Closure 처리
    private func handleClosure() {
        // Place Info 관련 클로저
        homeView.afterPhoneButtonTappedWhenNoData = { [weak self] in
            self?.afterPhoneButtonTappedWhenNoData?()
        }
        
        homeView.afterTimePlusButtonTapped = { [weak self] in
            self?.afterTimePlusButtonTapped?()
        }
        
        homeView.afterTimeTableShowButtonTapped = { [weak self] in
            self?.afterTimeTableShowButtonTapped?()
        }
        
        homeView.afterHomePageButtonTapped = { [weak self] url in
            self?.afterHomePageButtonTapped?(url)
        }
        
        homeView.afterEditInfoButtonTapped = { [weak self] in
            self?.afterEditInfoButtonTapped?()
        }
        
        // menu 관련 클로저
        homeView.showMoreMenu = { [weak self] in
            self?.segmentedControl.selectedSegmentIndex = 1
            self?.activeMenuView()
        }
        
        homeView.editMenu = { [weak self] in
            self?.editMenu?()
        }
        
        menuView.editMenuButton = { [weak self] in
            self?.editMenu?()
        }
        
        // Review 관련 클로저
        homeView.showMoreReviews = { [weak self] in
            self?.segmentedControl.selectedSegmentIndex = 2
            self?.activeReviewView()
        }
        
        homeView.showMoreReviewsAndWriteComment = { [weak self] in
            self?.pushReviewWriteView?(.home)
            //            self?.segmentedControl.selectedSegmentIndex = 2
            //            self?.activeReviewView()
            //            self?.reviewView.autoStartWriteComment()
        }
        
        homeView.deleteRequestButtonTapped = { [weak self] in
            self?.deleteRequestButtonTapped?()
        }
        
        reviewView.whenUploadReview = { [weak self] postReviewModel in
            self?.reviewsCount += 1
            self?.homeView.updateReview(postReviewModel)
            self?.whenUploadReview?(postReviewModel)
        }
        
        reviewView.whenAfterEditMyReview = { [weak self] postEditReviewModel in
            self?.homeView.whenAfterEditReview(postEditReviewModel)
            self?.whenAfterEditReview?(postEditReviewModel)
        }
        
        reviewView.whenReportReview = { [weak self] reportCommentModel in
            self?.reportReview?(reportCommentModel)
        }
        
        homeView.reportReview = { [weak self] reportCommentModel in
            self?.reportReview?(reportCommentModel)
        }
        
        reviewView.whenBeforeEditMyReview = { [weak self] (commentId, content) in
            self?.whenBeforeEditMyReview?(commentId, content)
        }
        
        homeView.whenBeforeEditMyReview = { [weak self] (commentId, content) in
            self?.whenBeforeEditMyReview?(commentId, content)
        }
        
        reviewView.pushReviewWriteView = { [weak self] in
            self?.pushReviewWriteView?(.review)
        }
    }
}

extension PlaceSegmentedControlView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 화면의 중앙값 계산
        let scrollViewCenterY = scrollView.contentOffset.y + scrollView.frame.size.height / 2
        
        // PlaceMenuView와 PlaceReviewsView의 중앙값 계산
        let placeMenuCenterY = homeView.placeMenuView.frame.origin.y + (homeView.placeMenuView.frame.height / 2)
        let placeReviewsCenterY = homeView.placeReviewsView.frame.origin.y + (homeView.placeReviewsView.frame.height / 2)
        
        // PlaceMenuView가 중앙에 있는지 확인
        if abs(scrollViewCenterY - placeMenuCenterY) < 50 && !isScrollUntilMenu {
            scrolledMenu?()
            isScrollUntilMenu.toggle()
        }
        
        // PlaceReviewsView가 중앙에 있는지 확인
        if abs(scrollViewCenterY - placeReviewsCenterY) < 50 && !isScrollUntilReview {
            scrolledReview?()
            isScrollUntilReview.toggle()
        }
    }
}
