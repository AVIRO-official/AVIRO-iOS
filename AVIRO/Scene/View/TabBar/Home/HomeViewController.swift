//
//  HomeViewController.swift
//  VeganRestaurant
//
//  Created by 전성훈 on 2023/05/19.
//

import UIKit

import NMapsMap

// MARK: Text
private enum Text: String {
    case yes = "예"
    case no = "아니오"
    case cancel = "취소"
    case more = "더보기"
    case edit = "수정하기"
    case delete = "삭제하기"
    case report = "신고하기"
    case searchPlaceHolder = "어디로 이동할까요?"
    
    case starPlus = "즐겨찾기가 추가되었습니다."
    case starDelete = "즐겨찾기가 삭제되었습니다."
    
    case reportReview = "후기 신고하기"
    case deleteMyReviewAlert = "정말로 삭제하시겠어요?\n삭제하면 다시 복구할 수 없어요."
    
    case reportPlace = "가게 신고하기"
    case reportPlaceReasonTitle = "신고 이유가 궁금해요!"
    
    case reasonLost = "없어진 가게예요"
    case reasonNotVegan = "비건 메뉴가 없는 가게예요"
    case reasonDuplicated = "중복 등록된 가게예요"
    
    case successReportPlaceTitle = "신고가 완료되었어요"
    case alreadyReportPlaceTitle = "이미 신고한 가계예요"
    case reportPlaceMessage = "3건 이상의 신고가 들어오면\n가게는 자동으로 삭제돼요."
    
    case editRequestSuccess = "수정 요청이 완료되었어요"
    case editSuccess = "수정 완료되었어요"

    case editRequestPlaceSubtitle = "조금만 기다려주세요!\n관리자가 매일 꼼꼼하게 검수하고 있어요."
    
    case editMenuSubtitle = "소중한 정보 감사해요.\n수정해주신 정보로 업데이트 되었어요!"
    
    case error = "에러"
    case retry = "제시도"
    
    case failLoadMarker = "마커 데이터를 불러오는데 실패 했습니다."
}

// MARK: Layout
private enum Layout {
    enum Margin: CGFloat {
        case small = 10
        case regular = 16
        case topButtonToView = 18
        case medium = 20
        case large = 30
        case largeToView = 40
    }
    
    enum Size: CGFloat {
        case topButtonSize = 50
    }
}

final class HomeViewController: UIViewController {
    lazy var presenter = HomeViewPresenter(viewController: self)
        
    // MARK: UI Property Definitions
    private lazy var naverMapView: NMFMapView = {
        let map = NMFMapView()
            
        map.addCameraDelegate(delegate: self)
        map.touchDelegate = self

        map.mapType = .basic
        map.isIndoorMapEnabled = true
        map.minZoomLevel = 5.0
        map.extent = NMGLatLngBounds(
            southWestLat: 31.43,
            southWestLng: 122.37,
            northEastLat: 44.35,
            northEastLng: 132
        )
        
        return map
    }()
    
    private lazy var searchTextField: MainField = {
        let field = MainField()
        
        field.makePlaceHolder(Text.searchPlaceHolder.rawValue)
        field.makeShadow()
        field.delegate = self
        
        return field
    }()

    private lazy var loadLocationButton: HomeMapReferButton = {
        let button = HomeMapReferButton()
        
        button.setImage(
            UIImage.currentButton.withTintColor(.gray1),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(locationButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var starButton: HomeMapReferButton = {
        let button = HomeMapReferButton()
        
        button.setImage(
            UIImage.starIcon.withTintColor(.gray1),
            for: .normal
        )
        button.setImage(
            UIImage.starIconClicked,
            for: .selected
        )
        button.addTarget(
            self,
            action: #selector(starButtonTapped(_ :)),
            for: .touchUpInside
        )

        return button
    }()
    
    private lazy var downBackButton: HomeTopButton = {
        let button = HomeTopButton()
        
        button.setImage(
            UIImage.downBack,
            for: .normal
        )
        
        button.addTarget(
            self,
            action: #selector(downBackButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var flagButton: HomeTopButton = {
        let button = HomeTopButton()
        
        button.setImage(
            UIImage.flag,
            for: .normal
        )
        
        button.addTarget(
            self,
            action: #selector(flagButtonTapped(_:)),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private(set) lazy var placeView = PlaceView()
        
    private(set) var placeViewTopConstraint: NSLayoutConstraint?
    private(set) var searchTextFieldTopConstraint: NSLayoutConstraint?
    
    private lazy var isSlideUpView = false

    private lazy var tapGesture = UITapGestureRecognizer()
    private lazy var upGesture = UISwipeGestureRecognizer()
    private lazy var downGesture = UISwipeGestureRecognizer()

    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
    
        presenter.viewDidLoad()
        handleClosure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        naverMapView.liteModeEnabled = true
    }
}

extension HomeViewController: HomeViewProtocol {
    // MARK: Set up func
    func setupLayout() {
        [
            naverMapView,
            loadLocationButton,
            starButton,
            searchTextField,
            placeView,
            flagButton,
            downBackButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            naverMapView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            naverMapView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Layout.Margin.largeToView.rawValue
            ),
            naverMapView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            naverMapView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            
            loadLocationButton.bottomAnchor.constraint(
                equalTo: placeView.topAnchor,
                constant: -Layout.Margin.medium.rawValue
            ),
            loadLocationButton.trailingAnchor.constraint(
                equalTo: naverMapView.trailingAnchor,
                constant: -Layout.Margin.medium.rawValue
            ),
            
            starButton.bottomAnchor.constraint(
                equalTo: loadLocationButton.topAnchor,
                constant: -Layout.Margin.small.rawValue
            ),
            starButton.trailingAnchor.constraint(
                equalTo: loadLocationButton.trailingAnchor
            ),
            
            searchTextField.leadingAnchor.constraint(
                equalTo: naverMapView.leadingAnchor,
                constant: Layout.Margin.regular.rawValue
            ),
            searchTextField.trailingAnchor.constraint(
                equalTo: naverMapView.trailingAnchor,
                constant: -Layout.Margin.regular.rawValue
            ),
            
            placeView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            placeView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            placeView.heightAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.heightAnchor
            ),

            flagButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -Layout.Margin.regular.rawValue
            ),
            flagButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Layout.Margin.topButtonToView.rawValue
            ),
            flagButton.widthAnchor.constraint(equalToConstant: Layout.Size.topButtonSize.rawValue),
            flagButton.heightAnchor.constraint(equalToConstant: Layout.Size.topButtonSize.rawValue),
            
            downBackButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: Layout.Margin.regular.rawValue
            ),
            downBackButton.topAnchor.constraint(
                equalTo: flagButton.topAnchor
            ),
            downBackButton.widthAnchor.constraint(equalToConstant: Layout.Size.topButtonSize.rawValue),
            downBackButton.heightAnchor.constraint(equalToConstant: Layout.Size.topButtonSize.rawValue)
        ])
                        
        searchTextFieldTopConstraint = searchTextField.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Layout.Margin.regular.rawValue
        )
        searchTextFieldTopConstraint?.isActive = true
        
        placeViewTopConstraint = placeView.topAnchor.constraint(
            equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
        )
        placeViewTopConstraint?.isActive = true
    }
    
    func setupAttribute() {
        view.backgroundColor = .gray7
        
        if let tabBarController = tabBarController as? TabBarViewController {
            // home 화면 초기화
            tabBarController.homeTabBarButtonTapped = { [weak self] in
                self?.presenter.initMarkerState()
                self?.whenViewWillAppearInitPlaceView()
                self?.afterSearchFieldInit()
                self?.naverMapView.isHidden = false
            }
        }
    }
    
    func setupGesture() {
        tapGesture.delegate = self

        upGesture.direction = .up
        downGesture.direction = .down
        
        upGesture.addTarget(
            self,
            action: #selector(swipeGestureActived(_:))
        )
        downGesture.addTarget(
            self,
            action: #selector(swipeGestureActived(_:))
        )
        
        placeView.addGestureRecognizer(upGesture)
        placeView.addGestureRecognizer(downGesture)
        view.addGestureRecognizer(tapGesture)
    }
    
    /// 기본 값 view will appear
    func whenViewWillAppear() {
        navigationController?.navigationBar.isHidden = true
        
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.hiddenTabBar(false)
        }
        
        naverMapView.isHidden = false
    }
    
    /// 모든 조건에 해당 사항 없을 때, place view 초기화
    func whenViewWillAppearOffAllCondition() {
        whenViewWillAppearInitPlaceView()
    }
    
    /// Edit 화면에서 돌아올 때
    func whenAfterPopEditViewController() {
        naverMapView.isHidden = true
    }
    
    // MARK: UI Interactions
    /// 댓글 입력할때 keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            let keyboardHeight = keyboardFrame.height
            
            let tabbarHeight = tabBarController?.tabBar.frame.height ?? 0
            
            let result = keyboardHeight - tabbarHeight
            
            placeView.keyboardWillShow(notification: notification, height: result)
        }
    }
 
    func keyboardWillHide() {
        placeView.keyboardWillHide()
    }
    
    /// location button clicked
    func isSuccessLocation() {
        
        naverMapView.positionMode = .direction
    }
    
    /// location button clicked
    func ifDeniedLocation(_ mapCoor: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(
            scrollTo: mapCoor
        )
        naverMapView.moveCamera(cameraUpdate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showDeniedLocationAlert()
        }
    }

    /// 최초 load markers
    func loadMarkers(with markers: [NMFMarker]) {
        
        markers.forEach {
            $0.mapView = naverMapView
        }
    }
    
    /// star button clicked
    func afterLoadStarButton(with noStars: [NMFMarker]) {
        noStars.forEach {
            $0.mapView = nil
        }
    }
    
    func moveToCameraWhenNoAVIRO(_ lng: Double, _ lat: Double) {
        let latlng = NMGLatLng(lat: lat, lng: lng)
        let cameraUpdate = NMFCameraUpdate(scrollTo: latlng, zoomTo: 14)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.25

        naverMapView.moveCamera(cameraUpdate)
    }
    
    func moveToCameraWhenHasAVIRO(_ markerModel: MarkerModel, zoomTo: Double? = nil) {
        let latlng = markerModel.marker.position
        
        var cameraUpdate = NMFCameraUpdate()
        
        let currentZoomLevel = naverMapView.zoomLevel
        
        if let zoomTo = zoomTo {
            cameraUpdate = NMFCameraUpdate(scrollTo: latlng, zoomTo: zoomTo)
        } else if currentZoomLevel <= 10 {
            cameraUpdate = NMFCameraUpdate(scrollTo: latlng, zoomTo: 10.5)
        } else {
            cameraUpdate = NMFCameraUpdate(scrollTo: latlng)
        }
        
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.25
        popupPlaceView()
        naverMapView.moveCamera(cameraUpdate)
    }
    
    private func popupPlaceView() {
        placeViewPopUp()
        isSlideUpView = false
        placeView.isLoadingTopView = true
    }
    
    func afterClickedMarker(
        placeModel: PlaceTopModel,
        placeId: String,
        isStar: Bool
    ) {
        placeView.summaryDataBinding(
            placeModel: placeModel,
            placeId: placeId,
            isStar: isStar
        )
        
        changedSearchField(with: placeModel.placeTitle)
    }
    
    func afterSlideupPlaceView(
        infoModel: AVIROPlaceInfo?,
        menuModel: AVIROPlaceMenus?,
        reviewsModel: AVIROReviewsArray?
    ) {
        placeView.allDataBinding(
            infoModel: infoModel,
            menuModel: menuModel,
            reviewsModel: reviewsModel
        )
    }
    
    func updateMenus(_ menuData: AVIROPlaceMenus?) {
        DispatchQueue.main.async { [weak self] in
            self?.placeView.menuModelBinding(menuModel: menuData)
        }
    }
    
    func updateMapPlace(_ mapPlace: MapPlace) {
        placeView.updateMapPlace(mapPlace)
    }
    
    func deleteMyReview(_ commentId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.placeView.deleteMyReview(commentId)
        }
    }
    
    func openWebLink(url: URL) {
        presenter.shouldKeepPlaceInfoViewState(true)
        showWebView(with: url)
    }
    
    private func editMyReview(_ commentId: String) {
        placeView.editMyReview(commentId)
    }
    
    @objc private func downBackButtonTapped(_ sender: UIButton) {
        placeViewPopUpAfterInitPlacePopViewHeight()
        isSlideUpView = false
    }
    
    @objc private func flagButtonTapped(_ sender: UIButton) {
        presenter.checkReportPlaceDuplecated()
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        presenter.loadBookmark(sender.isSelected)
    }
    
    @objc private func locationButtonTapped(_ sender: UIButton) {
        presenter.locationUpdate()
    }
    
    @objc private func swipeGestureActived(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up {
            // TopView가 로딩이 다 끝난 후 가능
            if !placeView.isLoadingTopView {
                // view가 slideup되고, detail view가 loading이 끝난 후 가능
                if isSlideUpView && !placeView.isLoadingDetail {
                    placeViewFullUp()
                    naverMapView.isHidden = true
                    isSlideUpView = false
                // view가 아직 slideup 안 되었고, popup일때 가능
                } else if !isSlideUpView && placeView.placeViewStated == .popup {
                    placeViewSlideUp()
                    presenter.getPlaceModelDetail()
                    isSlideUpView = true
                }
            }
        } else if gesture.direction == .down {
            // view가 slideup일때만 down gesture 가능
            if isSlideUpView {
                placeViewPopUpAfterInitPlacePopViewHeight()
                isSlideUpView = false
            }
        }
    }
    
    func homeButtonIsHidden(_ hidden: Bool) {
        loadLocationButton.isHidden = hidden
        starButton.isHidden = hidden
    }
    
    func viewNaviButtonHidden(_ hidden: Bool) {
        downBackButton.isHidden = hidden
        flagButton.isHidden = hidden
    }
    
    func moveToCameraWhenSlideUpView() {
        let yPosition = naverMapView.frame.height * 1/4
        let point = CGPoint(x: 0, y: -yPosition)
        
        let cameraUpdate = NMFCameraUpdate(scrollBy: point)
        cameraUpdate.animation = .linear
        cameraUpdate.animationDuration = 0.2
        
        naverMapView.moveCamera(cameraUpdate)
    }
    
    func moveToCameraWhenPopupView() {
        let yPosition = naverMapView.frame.height * 1/4
        let point = CGPoint(x: 0, y: yPosition)
        
        let cameraUpdate = NMFCameraUpdate(scrollBy: point)
        cameraUpdate.animation = .linear
        cameraUpdate.animationDuration = 0.2
        
        naverMapView.moveCamera(cameraUpdate)
    }
    
    // MARK: Push Interactions
    func pushPlaceInfoOpreationHoursViewController(_ models: [EditOperationHoursModel]) {
        DispatchQueue.main.async { [weak self] in
            let vc = PlaceOperationHoursViewController(models)
            
            vc.modalPresentationStyle = .overFullScreen
            
            self?.present(vc, animated: false)
        }
    }
    
    func pushEditPlaceInfoViewController(
        placeMarkerModel: MarkerModel,
        placeId: String,
        placeSummary: AVIROPlaceSummary,
        placeInfo: AVIROPlaceInfo,
        editSegmentedIndex: Int
    ) {
        let vc = EditPlaceInfoViewController()
        let presenter = EditPlaceInfoPresenter(
            viewController: vc,
            placeMarkerModel: placeMarkerModel,
            placeId: placeId,
            placeSummary: placeSummary,
            placeInfo: placeInfo,
            selectedIndex: editSegmentedIndex
        )
        
        vc.presenter = presenter
        
        presenter.afterReportShowAlert = { [weak self] in
            self?.showAlert(
                title: Text.editRequestSuccess.rawValue,
                message: Text.editRequestPlaceSubtitle.rawValue
            )
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushEditMenuViewController(
        placeId: String,
        isAll: Bool,
        isSome: Bool,
        isRequest: Bool,
        menuArray: [AVIROMenu]
    ) {
        let vc = EditMenuViewController()
        
        let presenter = EditMenuPresenter(
            viewController: vc,
            placeId: placeId,
            isAll: isAll,
            isSome: isSome,
            isRequest: isRequest,
            menuArray: menuArray
        )
        
        presenter.afterEditMenuChangedMenus = { [weak self] in
            DispatchQueue.main.async {
                self?.showAlert(
                    title: Text.editSuccess.rawValue,
                    message: Text.editMenuSubtitle.rawValue
                )
                self?.presenter.afterEditMenu()
            }
        }
        
        presenter.afterEditMenuChangedVeganMarker = { [weak self] changedMarkerModel in
            DispatchQueue.main.async {
                self?.presenter.afterEditMenuChangedMarker(changedMarkerModel)
            }
        }
        
        vc.presenter = presenter
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentReportReview(_ reportIdModel: AVIROReportReviewModel) {
        let vc = ReportReviewViewController()
        let presenter = ReportReviewPresenter(
            viewController: vc,
            reportIdModel: reportIdModel
        )
        
        presenter.afterReportPopView = { [weak self] text in
            self?.showToastAlert(text)
        }
        
        vc.presenter = presenter
        
        present(vc, animated: true)
    }
    
    // MARK: Alert Interactions
    func showActionSheetWhenSuccessReport() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(
                title: Text.successReportPlaceTitle.rawValue,
                message: Text.reportPlaceMessage.rawValue
            )
        }
    }
    
    func showToastAlert(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showSimpleToast(with: title)
        }
    }
    
    func showAlertWhenReportPlace() {
        DispatchQueue.main.async { [weak self] in
            let reportPlace: AlertAction = (
                title: Text.reportPlace.rawValue,
                style: .destructive,
                handler: {
                    self?.showActionSheetHowToReportPlace()
                }
            )
            
            let cancel: AlertAction = (
                title: Text.cancel.rawValue,
                style: .cancel,
                handler: nil
            )
            
            self?.showAlert(
                title: nil,
                message: Text.report.rawValue,
                actions: [reportPlace, cancel]
            )
        }
    }
    
    private func showActionSheetHowToReportPlace() {
        let lostPlace: AlertAction = (
            title: Text.reasonLost.rawValue,
            style: .default,
            handler: {
                let type = AVIROReportPlaceType.noPlace
                self.presenter.reportPlace(type)
            }
        )
        
        let notVeganPlace: AlertAction = (
            title: Text.reasonNotVegan.rawValue,
            style: .default,
            handler: {
                let type = AVIROReportPlaceType.noVegan
                self.presenter.reportPlace(type)
            }
        )
        
        let duplicatedPlace: AlertAction = (
            title: Text.reasonDuplicated.rawValue,
            style: .default,
            handler: {
                let type = AVIROReportPlaceType.dubplicatedPlace
                self.presenter.reportPlace(type)
            }
        )
        
        let cancel: AlertAction = (
            title: Text.cancel.rawValue,
            style: .cancel,
            handler: nil
        )
        
        showAlert(
            title: Text.reportPlaceReasonTitle.rawValue,
            message: Text.reportPlaceMessage.rawValue,
            actions: [
                lostPlace,
                notVeganPlace,
                duplicatedPlace,
                cancel
            ]
        )
    }

    func showAlertWhenDuplicatedReport() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(
                title: Text.alreadyReportPlaceTitle.rawValue,
                message: Text.reportPlaceMessage.rawValue
            )
        }
    }
    
    private func showReportReviewAlert(_ reportCommentModel: AVIROReportReviewModel) {
        let reportAction: AlertAction = (
            title: Text.reportReview.rawValue,
            style: .destructive,
            handler: {
                let finalReportCommentModel = AVIROReportReviewModel(
                    createdTime: reportCommentModel.createdTime,
                    placeTitle: self.presenter.getPlace(),
                    id: reportCommentModel.id,
                    content: reportCommentModel.content,
                    nickname: reportCommentModel.nickname
                )
                self.presentReportReview(finalReportCommentModel)
            }
        )
        
        let cancelAction: AlertAction = (
            title: Text.cancel.rawValue,
            style: .cancel,
            handler: nil
        )
        
        showActionSheet(
            title: nil,
            message: Text.more.rawValue,
            actions: [reportAction, cancelAction]
        )
    }
    
    private func showEditMyReviewAlert(_ commentId: String) {
        let editMyReviewAction: AlertAction = (
            title: Text.edit.rawValue,
            style: .default,
            handler: {
                self.editMyReview(commentId)
            }
        )
        
        let deleteMyReviewAction: AlertAction = (
            title: Text.delete.rawValue,
            style: .destructive,
            handler: {
                self.showDeleteMyReviewAlert(commentId)
            }
        )
        
        let cancelAction: AlertAction = (
            title: Text.cancel.rawValue,
            style: .cancel,
            handler: nil
        )
        showActionSheet(
            title: nil,
            message: Text.more.rawValue,
            actions: [
                editMyReviewAction,
                deleteMyReviewAction,
                cancelAction
            ]
        )
    }
    
    private func showDeleteMyReviewAlert(_ commentId: String) {
        let deleteMyReview: AlertAction = (
            title: Text.yes.rawValue,
            style: .destructive,
            handler: {
                let deleteCommentModel = AVIRODeleteReveiwDTO(
                    commentId: commentId,
                    userId: MyData.my.id
                )
                
                self.presenter.deleteMyReview(deleteCommentModel)
            }
        )
        
        let cancel: AlertAction = (
            title: Text.no.rawValue,
            style: .default,
            handler: nil
        )
        
        showAlert(
            title: Text.delete.rawValue,
            message: Text.deleteMyReviewAlert.rawValue,
            actions: [deleteMyReview, cancel]
        )
    }
    
    func showErrorAlert(with error: String, title: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let title = title {
                self?.showAlert(title: title, message: error)
            } else {
                self?.showAlert(title: Text.error.rawValue, message: error)
            }
        }
    }
    
    func showErrorAlertWhenLoadMarker() {
        DispatchQueue.main.async { [weak self] in
            let action: AlertAction = (
                title: Text.retry.rawValue,
                style: .destructive,
                handler: {
                    self?.presenter.loadVeganData()
                }
            )
            
            self?.showAlert(
                title: Text.error.rawValue,
                message: Text.failLoadMarker.rawValue,
                actions: [action]
            )
        }
    }
}

// MARK: Handle Closure
extension HomeViewController {
    private func handleClosure() {
        placeView.whenFullBack = { [weak self] in
            self?.naverMapView.isHidden = false
            self?.placeViewPopUpAfterInitPlacePopViewHeight()
        }
        
        placeView.whenShareTapped = { [weak self] shareObject in
            self?.showShareAlert(with: shareObject)
        }
        
        placeView.whenTopViewStarTapped = { [weak self] selected in
            let title: String = selected ? Text.starPlus.rawValue : Text.starDelete.rawValue
            
            self?.showToastAlert(title)
            self?.presenter.updateBookmark(selected)
        }
            
        placeView.afterPhoneButtonTappedWhenNoData = { [weak self] in
            self?.presenter.editPlaceInfo(withSelectedSegmentedControl: 1)
        }
        
        placeView.afterTimePlusButtonTapped = { [weak self] in
            self?.presenter.editPlaceInfo(withSelectedSegmentedControl: 2)
        }
        
        placeView.afterTimeTableShowButtonTapped = { [weak self] in
            self?.presenter.loadPlaceOperationHours()
        }
        
        placeView.afterHomePageButtonTapped = { [weak self] urlString in
            self?.presenter.openHomepageURL(with: urlString)
        }
        
        placeView.afterEditInfoButtonTapped = { [weak self] in
            self?.presenter.editPlaceInfo()
        }
        
        placeView.editMenu = { [weak self] in
            self?.presenter.editMenu()
        }
        
        placeView.whenUploadReview = { [weak self] postReviewModel in
            self?.presenter.uploadReview(postReviewModel)
        }
        
        placeView.whenAfterEditReview = { [weak self] postReviewEditModel in
            self?.presenter.editMyReview(postReviewEditModel)
        }
    
        placeView.reportReview = { [weak self] reportIdModel in
            self?.showReportReviewAlert(reportIdModel)
        }
        
        placeView.editMyReview = { [weak self] commentId in
            self?.showEditMyReviewAlert(commentId)
        }
        
        placeView.test = { [weak self] in
            let vc = ReviewWriteViewController()
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: TapGestureDelegate
extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if touch.view is PushCommentView || touch.view is UITextView || touch.view is UIButton {
            return false
        }
        
        view.endEditing(true)
        return true
    }
}

// MARK: UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        animateTextFieldExpansion(textField: textField)
        return false
    }
    
    private func animateTextFieldExpansion(textField: UITextField) {
        textField.placeholder = ""
        textField.text = ""
        textField.leftView?.isHidden = true
        
        let startingFrame = textField.convert(textField.bounds, to: nil)
        
        textField.activeExpansion(from: startingFrame, to: self.view) { [weak self] in
            let vc = HomeSearchViewController()
            
            let presenter = HomeSearchPresenter(viewController: vc)
            
            vc.presenter = presenter
            
            presenter.selectedPlace = { [weak self] place in
                self?.changedSearchField(with: place)
            }
            
            self?.navigationController?.pushViewController(vc, animated: false)
            
            textField.leftView?.isHidden = false
            textField.placeholder = Text.searchPlaceHolder.rawValue
        }
    }
    
    private func changedSearchField(with place: String) {
        searchTextField.text = place
    }
    
    private func afterSearchFieldInit() {
        searchTextField.text = ""
    }
}

// MARK: NMFMapViewCameraDelegate
extension HomeViewController: NMFMapViewCameraDelegate {
    func mapView(
        _ mapView: NMFMapView,
        cameraDidChangeByReason reason: Int,
        animated: Bool
    ) {
        /// 검색 기준을 잡기 위한 지도 중심 좌표 저장 메소드
        saveCenterCoordinate()
    }
    
    private func saveCenterCoordinate() {
        let center = naverMapView.cameraPosition.target
        
        presenter.saveCenterCoordinate(center)
    }
    
    func mapView(
        _ mapView: NMFMapView,
        cameraWillChangeByReason reason: Int,
        animated: Bool
    ) {
        if placeView.placeViewStated == .noShow {
            afterSearchFieldInit()
        }
    }
    
}

// MARK: NMFMapViewTouchDelegate
extension HomeViewController: NMFMapViewTouchDelegate {
    func mapView(
        _ mapView: NMFMapView,
        didTapMap latlng: NMGLatLng,
        point: CGPoint
    ) {
        whenClosedPlaceView()
        isSlideUpView = false
    }
}
