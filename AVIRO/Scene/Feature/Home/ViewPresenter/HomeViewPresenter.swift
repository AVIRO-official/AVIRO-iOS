//
//  HomeViewPresenter.swift
//  VeganRestaurant
//
//  Created by 전성훈 on 2023/05/19.
//

import UIKit
import CoreLocation

import NMapsMap

protocol HomeViewProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    func setupGesture()
        
    func whenViewWillAppear()
    func whenViewWillAppearOffAllCondition()
    func whenAfterPopEditViewController()

    func isFectingData()
    func endFectingData()
//    func keyboardWillShow(notification: NSNotification)
//    func keyboardWillHide()
//    
    func isSuccessLocation()
    func ifDeniedLocation(_ mapCoor: NMGLatLng)

    func loadMarkers(with markers: [NMFMarker])
    func afterLoadStarButton(with noStars: [NMFMarker])

    func moveToCameraWhenNoAVIRO(_ lng: Double, _ lat: Double)
    func moveToCameraWhenHasAVIRO(_ markerModel: MarkerModel, zoomTo: Double?)
    
    func afterClickedMarker(placeModel: PlaceTopModel, placeId: String, isStar: Bool)
    func afterSlideupPlaceView(
        infoModel: AVIROPlaceInfo?,
        menuModel: AVIROPlaceMenus?,
        reviewsModel: AVIROReviewsArray?
    )
    
    func updateMenus(_ menuData: AVIROPlaceMenus?)
    func updateMapPlace(_ mapPlace: VeganType)
    func deleteMyReview(_ commentId: String)
    
    func pushPlaceInfoOpreationHoursViewController(_ models: [EditOperationHoursModel])
    func pushEditPlaceInfoViewController(
        placeMarkerModel: MarkerModel,
        placeId: String,
        placeSummary: AVIROPlaceSummary,
        placeInfo: AVIROPlaceInfo,
        editSegmentedIndex: Int
    )
    func pushEditMenuViewController(placeId: String, isAll: Bool, isSome: Bool, isRequest: Bool, menuArray: [AVIROMenu])
    func pushReviewWriteView(with viewModel: ReviewWriteViewModel)

    func openWebLink(url: URL)
    func showActionSheetWhenSuccessReport()
    func showToastAlert(_ title: String)
    func showAlertWhenReportPlace()
    func showAlertWhenDuplicatedReport()
    func showErrorAlert(with error: String, title: String?)
    func showErrorAlertWhenLoadMarker()
}

final class HomeViewPresenter: NSObject {
    weak var viewController: HomeViewProtocol?
    
    private let markerModelManager: MarkerModelManagerProtocol
    private let bookmarkManager: BookmarkFacadeProtocol
    private let amplitude: AmplitudeProtocol
    private let locationManager = CLLocationManager()

    var homeMapData: [AVIROMarkerModel]?
    
    private var hasTouchedMarkerBefore = false
    private var whenShowPlaceAfterActionFromChildViewController = false
    private var isFirstViewWillappear = true
    private var whenKeepPlaceInfoView = false
    
    private var selectedMarkerIndex = 0 
    private var selectedMarkerModel: MarkerModel?
    private var selectedSummaryModel: AVIROPlaceSummary?
    private var selectedInfoModel: AVIROPlaceInfo?
    private var selectedMenuModel: AVIROPlaceMenus?
    private var selectedReviewsModel: AVIROReviewsArray?
        
    private var selectedPlaceId: String?
        
    init(viewController: HomeViewProtocol,
         markerManager: MarkerModelManagerProtocol = MarkerModelManager(),
         bookmarkManager: BookmarkFacadeProtocol = BookmarkFacadeManager(),
         amplitude: AmplitudeProtocol = AmplitudeUtility()
    ) {
        self.viewController = viewController
        
        self.markerModelManager = markerManager
        self.bookmarkManager = bookmarkManager
        self.amplitude = amplitude
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(NotiName.afterMainSearch.rawValue),
            object: nil
        )
    }
    
    func viewDidLoad() {
        locationManager.delegate = self
        
        MyCoordinate.shared.afterFirstLoadLocation = { [weak self] in
            self?.loadVeganData()
        }
            
        setNotification()
        
        viewController?.setupLayout()
        viewController?.setupAttribute()
        viewController?.setupGesture()
                
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(afterMainSearchPlace(_:)),
            name: NSNotification.Name(NotiName.afterMainSearch.rawValue),
            object: nil
        )
    }
    
    func viewWillAppear() {
//        addKeyboardNotification()
        
        handleMarkerUpdate()
        handleViewWillAppearActions()
    }
    
    private func handleMarkerUpdate() {
        if !whenKeepPlaceInfoView && !isFirstViewWillappear {
            refreshMapMarkers()
        }
    }
    
    private func handleViewWillAppearActions() {
        viewController?.whenViewWillAppear()
        
        if isFirstViewWillappear {
            isFirstViewWillappear.toggle()
            
            return
        }
        
        if whenKeepPlaceInfoView { return }
        
        if !whenShowPlaceAfterActionFromChildViewController {
            viewController?.whenViewWillAppearOffAllCondition()
        }
    }
    
    func viewDidAppear() {
        if whenKeepPlaceInfoView {
            viewController?.whenAfterPopEditViewController()
            whenKeepPlaceInfoView.toggle()
        }
    }
    
    func viewWillDisappear() {
        if whenShowPlaceAfterActionFromChildViewController {
            whenShowPlaceAfterActionFromChildViewController.toggle()
        }
        
        if !whenKeepPlaceInfoView {
            initMarkerState()
        }
    }
    
    // MARK: 전화, url 들어가고 난 후에도 계속 place 정보 보여주기 위한 함수
    func shouldKeepPlaceInfoViewState(_ state: Bool) {
        whenKeepPlaceInfoView = state
    }
    
    // MARK: vegan Data 불러오기
    func loadVeganData() {
        viewController?.isFectingData()
        
        markerModelManager.fetchRawData { [weak self] result in
            switch result {
            case .success(let mapDatas):
                self?.saveMarkers(mapDatas)
                self?.viewController?.endFectingData()
            case .failure:
                self?.viewController?.endFectingData()
                self?.viewController?.showErrorAlertWhenLoadMarker()
            }
        }

        bookmarkManager.fetchAllData { [weak self] error in
            self?.viewController?.showErrorAlert(with: error, title: nil)
        }
    }
    
    private func saveMarkers(_ mapData: [AVIROMarkerModel]) {
        var markerModels = [MarkerModel]()

        mapData.forEach { data in
            let markerModel = createMarker(from: data)
            markerModels.append(markerModel)
        }
        
        markerModelManager.setAllMarkerModels(with: markerModels)
        
        DispatchQueue.main.async { [weak self] in
            if let markers = self?.markerModelManager.getAllMarkers() {
                self?.viewController?.loadMarkers(with: markers)
            }
        }
    }
    
    // MARK: Refresh Vegan Data
    private func refreshMapMarkers() {
        markerModelManager.updateRawDataWhenViewWillAppear { [weak self] result in
            switch result {
            case .success(let markerRawModels):
                self?.updateMarkers(markerRawModels)
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }

    }
    
    private func updateMarkers(_ mapData: [AVIROMarkerModel]?) {
        guard let mapData = mapData else { return }
        
        let uniqueMapData = Array(Set(mapData))

        uniqueMapData.forEach { data in
            let markerModel = createMarker(from: data)
            markerModelManager.updateMarkerModels(with: markerModel)
        }
        
        DispatchQueue.main.async { [weak self] in
            if let markers = self?.markerModelManager.getUpdatedMarkers() {
                self?.viewController?.loadMarkers(with: markers)
            }
            
            /// 본인이 직접등록한 마커에 대해서 등록 후 -> 바로 표시를 위한 조치
            if CenterCoordinate.shared.isChangedFromEnrollView {
                self?.whenShowPlaceAfterActionFromChildViewController = true
                
                self?.whenAfterEnrollPlace()
            }
        }
    }
    
    private func whenAfterEnrollPlace() {
        guard let lat = CenterCoordinate.shared.latitude,
              let lng = CenterCoordinate.shared.longitude
        else { return }
        
        let (markerModel, index) = markerModelManager.getMarkerModelFromCoordinates(lat: lat, lng: lng)
        
        guard let markerModel = markerModel,
              let index = index else { return }
        
        getPlaceSummaryModel(markerModel)
        
        hasTouchedMarkerBefore = true
        
        selectedMarkerIndex = index
        selectedMarkerModel = markerModel
        selectedMarkerModel?.isClicked = true
                
        markerModelManager.updateMarkerModelWhenClicked(with: selectedMarkerModel!)
        viewController?.moveToCameraWhenHasAVIRO(markerModel, zoomTo: 14)
        
        CenterCoordinate.shared.isChangedFromEnrollView = false
    }
    
    // MARK: Create Marker
    /// 마커만들기
    private func createMarker(from data: AVIROMarkerModel) -> MarkerModel {
        let latLng = NMGLatLng(lat: data.y, lng: data.x)
        let marker = NMFMarker(position: latLng)
        let placeId = data.placeId
        var veganType: VeganType
        var categoryType: CategoryType
        
        // TODO: - String에서 Enum으로 변경 필요 (Network DTO 값을 Domain으로 변경하도록 Refectoring 필요)
        /// Clean Architecture 적용 하면서 수행
        if data.allVegan {
            veganType = .All
        } else if data.someMenuVegan {
            veganType = .Some
        } else {
            veganType = .Request
        }
        
        
        /// 빵집 / 술집 /
        if data.category == "빵집" {
            categoryType = .Bread
        } else if data.category == "술집" {
            categoryType = .Bar
        } else if data.category == "식당" {
            categoryType = .Restaurant
        } else if data.category == "카페" {
            categoryType = .Coffee
        } else {
            // 값이 아에 없을때 확인
            categoryType = .Restaurant
        }
        
        
        marker.makeIcon(veganType: veganType, categoryType: categoryType)
        marker.touchHandler = { [weak self] _ in
            self?.touchedMarker(marker)
            return true
        }
        
        let markerModel =  MarkerModel(
            placeId: placeId,
            marker: marker,
            veganType: veganType,
            categoryType: categoryType,
            isAll: data.allVegan,
            isSome: data.someMenuVegan,
            isRequest: data.ifRequestVegan
        )
                
        return markerModel
    }
    
    // MARK: Marker Touched Method
    private func touchedMarker(_ marker: NMFMarker) {
        resetPreviouslyTouchedMarker()
        
        setMarkerToTouchedState(marker)
    }
    
    func initMarkerState() {
        resetPreviouslyTouchedMarker()
    }

    private func resetPreviouslyTouchedMarker() {
       /// 최초 터치 이후 작동을 위한 분기처리
        if hasTouchedMarkerBefore {
            if var selectedMarkerModel = selectedMarkerModel {
                selectedMarkerModel.isClicked = false
                markerModelManager.updateMarkerModelWhenClicked(with: selectedMarkerModel)
            }
            
            selectedMarkerModel = nil
            selectedMarkerIndex = 0
            selectedPlaceId = nil
            selectedInfoModel = nil
            selectedMenuModel = nil
            selectedReviewsModel = nil
            selectedSummaryModel = nil
        }
    }
    
    /// 클릭한 마커 저장 후 viewController에 알리기
    private func setMarkerToTouchedState(_ marker: NMFMarker) {
        let (markerModel, index) = markerModelManager.getMarkerModelFromMarker(with: marker)
                
        guard let validMarkerModel = markerModel else { return }
        
        guard let validIndex = index else { return }
        
        getPlaceSummaryModel(validMarkerModel)
        
        selectedMarkerIndex = validIndex
        selectedMarkerModel = validMarkerModel
        
        selectedMarkerModel?.isClicked = true

        hasTouchedMarkerBefore = true
                
        markerModelManager.updateMarkerModelWhenClicked(with: selectedMarkerModel!)
        viewController?.moveToCameraWhenHasAVIRO(validMarkerModel, zoomTo: nil)
    }
    
    // MARK: Load Place Sumamry
    private func getPlaceSummaryModel(_ markerModel: MarkerModel) {
        let mapPlace = markerModel.veganType
        let placeX = markerModel.marker.position.lng
        let placeY = markerModel.marker.position.lat
        let placeId = markerModel.placeId

        selectedPlaceId = placeId
        
        AVIROAPI.manager.loadPlaceSummary(with: placeId) { [weak self] result in
            switch result {
            case .success(let summary):
                if summary.statusCode == 200 {
                    if let place = summary.data {
                        let distanceValue = LocationUtility.distanceMyLocation(
                            x_lng: placeX,
                            y_lat: placeY
                        )
                        let distanceString = String(distanceValue).convertDistanceUnit()
                        let reviewsCount = String(place.commentCount)
                        
                        self?.selectedSummaryModel = place
                        
                        let placeTopModel = PlaceTopModel(
                            placeState: mapPlace,
                            placeTitle: place.title,
                            placeCategory: place.category,
                            distance: distanceString,
                            reviewsCount: reviewsCount,
                            address: place.address
                        )
                        
                        self?.amplitude.popupPlace(with: place.title)
                        
                        DispatchQueue.main.async {
                            let isStar = self?.bookmarkManager.checkData(with: placeId)
                            
                            self?.viewController?.afterClickedMarker(
                                placeModel: placeTopModel,
                                placeId: placeId,
                                isStar: isStar ?? false
                            )
                        }
                    }
                } else {
                    if let message = summary.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
    
    // MARK: Save Center Coordinate
    func saveCenterCoordinate(_ coordinate: NMGLatLng) {
        CenterCoordinate.shared.longitude = coordinate.lng
        CenterCoordinate.shared.latitude = coordinate.lat
    }
    
    // MARK: Notification Method afterMainSearch
    @objc func afterMainSearchPlace(_ noficiation: Notification) {
        guard let checkIsInAVIRO = noficiation.userInfo?[NotiName.afterMainSearch.rawValue]
                as? MatchedPlaceModel else { return }
        
        afterMainSearch(checkIsInAVIRO)
    }
    
    // MARK: After Main Search Method
    private func afterMainSearch(_ afterSearchModel: MatchedPlaceModel) {
        // AVIRO에 데이터가 없을 때
        if !afterSearchModel.allVegan && !afterSearchModel.someVegan && !afterSearchModel.requestVegan {
            viewController?.moveToCameraWhenNoAVIRO(
                afterSearchModel.x,
                afterSearchModel.y
            )
        } else {
        // AVIRO에 데이터가 있을 때
            let (markerModel, index) = markerModelManager.getMarkerModelFromSerachModel(with: afterSearchModel)
            
            guard let markerModel = markerModel else { return }
            guard let index = index else { return }
            
            whenShowPlaceAfterActionFromChildViewController = true
                                    
            selectedMarkerIndex = index
            selectedMarkerModel = markerModel
            selectedMarkerModel?.isClicked = true
                        
            hasTouchedMarkerBefore = true
            
            getPlaceSummaryModel(markerModel)

            viewController?.moveToCameraWhenHasAVIRO(markerModel, zoomTo: 14)
        }
    }
    
    // MARK: Bookmark Load Method
    func loadBookmark(_ isSelected: Bool) {
        if isSelected {
            whenAfterLoadStarButtonTapped()
        } else {
            whenAfterLoadNotStarButtonTapped()
        }
    }
    
    private func whenAfterLoadStarButtonTapped() {
        let markersModel = self.markerModelManager.getAllMarkerModel()
        let bookmarks = self.bookmarkManager.loadAllData()
        
        var starMarkersModel: [MarkerModel] = []
        var noMarkers: [NMFMarker] = []
        
        DispatchQueue.global().async {
            markersModel.forEach { model in
                if bookmarks.contains(model.placeId) {
                    starMarkersModel.append(model)
                } else {
                    noMarkers.append(model.marker)
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.markerModelManager.updateMarkerModelWhenOnStarButton(
                    isTapped: true,
                    markerModel: starMarkersModel
                )
                self?.viewController?.afterLoadStarButton(with: noMarkers)
            }
        }
    }
    
    private func whenAfterLoadNotStarButtonTapped() {

        markerModelManager.updateMarkerModelWhenOnStarButton(
            isTapped: false,
            markerModel: nil
        )
        let markers = markerModelManager.getAllMarkers()

        viewController?.loadMarkers(with: markers)
    }
    
    // MARK: Bookmark Upload & Delete Method
    func updateBookmark(_ isSelected: Bool) {
        guard let placeId = selectedPlaceId else { return }
        
        if isSelected {
            bookmarkManager.updateData(with: placeId) { [weak self] error in
                self?.viewController?.showToastAlert(error)
            }
        } else {
            bookmarkManager.deleteData(with: placeId) { [weak self] error in
                self?.viewController?.showToastAlert(error)
            }
        }
    }
    
    // MARK: Get Place Model Detail
    func getPlaceModelDetail() {
        guard let placeId = selectedPlaceId else { return }

        let dispatchGroup = DispatchGroup()
        
        loadPlaceInfo(with: placeId, dispatchGroup: dispatchGroup)
        loadPlaceMenus(with: placeId, dispatchGroup: dispatchGroup)
        loadPlaceReviews(with: placeId, dispatchGroup: dispatchGroup)
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.viewController?.afterSlideupPlaceView(
                infoModel: self?.selectedInfoModel,
                menuModel: self?.selectedMenuModel,
                reviewsModel: self?.selectedReviewsModel
            )
        }
    }
    
    private func loadPlaceInfo(with placeId: String, dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        AVIROAPI.manager.loadPlaceInfo(with: placeId) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    self?.selectedInfoModel = model.data
                } else {
                    if let message = model.message {
                        self?.viewController?.showErrorAlert(with: message, title: "가게 에러")
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: "가게 에러")
                }
            }
        }
    }
    
    private func loadPlaceMenus(with placeId: String, dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        AVIROAPI.manager.loadMenus(with: placeId) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    self?.selectedMenuModel = model.data
                } else {
                    if let message = model.message {
                        self?.viewController?.showErrorAlert(with: message, title: "메뉴 에러")
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: "메뉴 에러")
                }
            }
        }
    }
    
    private func loadPlaceReviews(with placeId: String, dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        AVIROAPI.manager.loadReviews(with: placeId) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    self?.selectedReviewsModel = model.data
                } else {
                    if let message = model.message {
                        self?.viewController?.showErrorAlert(with: message, title: "후기 에러")
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: "후기 에러")
                }
            }
        }
    }
        
    func reportPlace(_ type: AVIROReportPlaceType) {
        guard let placeId = selectedPlaceId else { return }
        
        let model = AVIROReportPlaceDTO(
            placeId: placeId,
            userId: MyData.my.id,
            nickname: MyData.my.nickname,
            code: type.code
        )

        AVIROAPI.manager.reportPlace(with: model) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    self?.viewController?.showActionSheetWhenSuccessReport()
                } else {
                    if let message = success.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
    
    func checkReportPlaceDuplecated() {
        guard let placeId = selectedPlaceId else { return }
        
        let model = AVIROPlaceReportCheckDTO(
            placeId: placeId,
            userId: MyData.my.id
        )
        
        AVIROAPI.manager.checkPlaceReportIsDuplicated(with: model) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    if success.reported {
                        self?.viewController?.showAlertWhenDuplicatedReport()
                    } else {
                        self?.viewController?.showAlertWhenReportPlace()
                    }
                } else {
                    if let message = success.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }

    func getPlace() -> String {
        guard let place = selectedSummaryModel?.title else { return "" }
        return place
    }
    
    func loadPlaceOperationHours() {
        guard let placeId = selectedPlaceId else { return }
        
        AVIROAPI.manager.loadOperationHours(with: placeId) { [weak self] result in
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    if let model = model.data {
                        self?.viewController?.pushPlaceInfoOpreationHoursViewController(
                            model.toEditOperationHoursModels()
                        )
                    }
                } else {
                    if let message = model.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
    
    func editPlaceInfo(withSelectedSegmentedControl placeEditSegmentedIndex: Int = 0) {
        guard let placeMarkerModel = selectedMarkerModel,
              let placeId = selectedPlaceId,
              let placeSummary = selectedSummaryModel,
              let placeInfo = selectedInfoModel
        else { return }
        
        whenKeepPlaceInfoView = true
                
        viewController?.pushEditPlaceInfoViewController(
            placeMarkerModel: placeMarkerModel,
            placeId: placeId,
            placeSummary: placeSummary,
            placeInfo: placeInfo,
            editSegmentedIndex: placeEditSegmentedIndex
        )
    }
    
    func editMenu() {
        guard let placeMarkerModel = selectedMarkerModel,
              let placeMenuModel = selectedMenuModel
        else { return }
        
        let placeId = placeMarkerModel.placeId
        let isAll = placeMarkerModel.isAll
        let isSome = placeMarkerModel.isSome
        let isRequest = placeMarkerModel.isRequest
        let menuArray = placeMenuModel.menuArray
        
        whenKeepPlaceInfoView = true
        
        viewController?.pushEditMenuViewController(
            placeId: placeId,
            isAll: isAll,
            isSome: isSome,
            isRequest: isRequest,
            menuArray: menuArray
        )
    }
    
    func afterEditMenu() {
        guard let placeId = selectedPlaceId else { return }
        AVIROAPI.manager.loadMenus(with: placeId) { [weak self] result in
            switch result {
            case .success(let menuModel):
                if menuModel.statusCode == 200 {
                    if let model = menuModel.data {
                        self?.setAmplitudeWhenEditMenu(with: model.menuArray)
                        
                        self?.selectedMenuModel = model
                        self?.viewController?.updateMenus(model)
                    }
                } else {
                    if let message = menuModel.message {
                        self?.viewController?.showErrorAlert(with: message, title: nil)
                    }
                }
            case .failure(let error):
                self?.viewController?.showErrorAlert(with: error.localizedDescription, title: nil)
            }
        }
    }
    
    private func setAmplitudeWhenEditMenu(with menuArray: [AVIROMenu]) {
        guard let beforeMenus = selectedMenuModel?.menuArray,
              let place = selectedSummaryModel?.title
        else { return }
        
        amplitude.editMenu(
            with: place,
            beforeMenus: beforeMenus,
            afterMenus: menuArray
        )
    }
    
    // MARK: Menu변경 후 Marker Update
    /// 메뉴 변경시 비건 메뉴 구성 변경으로 인한 업데이트 조치
    func afterEditMenuChangedMarker(_ changedMarkerModel: EditMenuChangedMarkerModel) {
        guard var selectedMarkerModel = selectedMarkerModel else { return }

        selectedMarkerModel.veganType = changedMarkerModel.mapPlace
        selectedMarkerModel.isAll = changedMarkerModel.isAll
        selectedMarkerModel.isSome = changedMarkerModel.isSome
        selectedMarkerModel.isRequest = changedMarkerModel.isRequest

        self.selectedMarkerModel = selectedMarkerModel

        markerModelManager.updateSelectedMarkerModel(index: selectedMarkerIndex, model: selectedMarkerModel)
        
        viewController?.updateMapPlace(changedMarkerModel.mapPlace)
    }
    
    func recommendPlace() {
        guard let selectedPlaceId = selectedPlaceId else { return }
        
        let recommendModel = AVIRORecommendPlaceDTO(
            placeId: selectedPlaceId, 
            userId: MyData.my.id
        )
        
        AVIROAPI.manager.recommendPlace(with: recommendModel) { [weak self] result in
            switch result {
            case .success(let model):
                self?.viewController?.showToastAlert("귀중한 정보 감사합니다!")
            case .failure(let error):
                self?.viewController?.showErrorAlert(
                    with: error.errorDescription ?? "서버 오류",
                    title: nil
                )
            }
        }
    }
    
    func deleteMyReview(_ postDeleteReviewModel: AVIRODeleteReveiwDTO) {
        AVIROAPI.manager.deleteReview(with: postDeleteReviewModel) { [weak self] result in
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    self?.viewController?.deleteMyReview(postDeleteReviewModel.commentId)
                }
                
                if let message = model.message {
                    self?.viewController?.showToastAlert(message)
                }
            case .failure(let error):
                self?.viewController?.showErrorAlert(with: error.localizedDescription, title: nil)
            }
        }
    }
    
    // MARK: URL Condition
    func openHomepageURL(with urlString: String) {
        let instagram = "instagram"
        
        if urlString.contains(instagram) {
            if let instagramURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(instagramURL as URL) {
                    UIApplication.shared.open(
                        instagramURL as URL,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
        } else if urlString.isValidURL {
            if let webURL = URL(string: urlString) {
                viewController?.openWebLink(url: webURL)
            }
        } else {
            editPlaceInfo(withSelectedSegmentedControl: 3)
        }
    }
    
    // MARK: Push Review Write ViewController
    func pushReviewWriteView() {
        whenKeepPlaceInfoView = true

        guard let markerModel = selectedMarkerModel,
              let summaryModel = selectedSummaryModel,
              let infoModel = selectedInfoModel else { return }
        
        var image: UIImage!
        
        switch markerModel.veganType {
        case .All:
            image = .allCell
        case .Some:
            image = .someCell
        case .Request:
            image = .requestCell
        }
        
        let viewModel = ReviewWriteViewModel(
            placeId: markerModel.placeId,
            placeIcon: image,
            placeTitle: summaryModel.title,
            placeAddress: infoModel.address + " " + (infoModel.address2 ?? "")
        )
        
        viewController?.pushReviewWriteView(with: viewModel)
    }
    
    func pushReviewWriteViewWhenEditReview(
        _ commentId: String,
        _ content: String
    ) {
        whenKeepPlaceInfoView = true

        guard let markerModel = selectedMarkerModel,
              let summaryModel = selectedSummaryModel,
              let infoModel = selectedInfoModel else { return }
        
        var image: UIImage!
        
        switch markerModel.veganType {
        case .All:
            image = .allCell
        case .Some:
            image = .someCell
        case .Request:
            image = .requestCell
        }
        
        let viewModel = ReviewWriteViewModel(
            placeId: markerModel.placeId,
            placeIcon: image,
            placeTitle: summaryModel.title,
            placeAddress: infoModel.address + " " + (infoModel.address2 ?? ""),
            content: content,
            editCommentId: commentId
        )
        
        viewController?.pushReviewWriteView(with: viewModel)
    }
}

// MARK: CLLocationManagerDelegate
extension HomeViewPresenter: CLLocationManagerDelegate {
    func locationUpdate() {
        locationAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorization()
    }
    
    private func locationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        case .denied, .restricted:
            if !isFirstViewWillappear {
                ifDeniedLocation()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        MyCoordinate.shared.latitude = location.coordinate.latitude
        MyCoordinate.shared.longitude = location.coordinate.longitude

        if !MyCoordinate.shared.isFirstLoadLocation {
            MyCoordinate.shared.isFirstLoadLocation = true
        }
        
        locationManager.stopUpdatingLocation()
        
        viewController?.isSuccessLocation()
    }
    
    private func ifDeniedLocation() {
        MyCoordinate.shared.latitude = DefaultCoordinate.lat.rawValue
        MyCoordinate.shared.longitude = DefaultCoordinate.lng.rawValue

        if !MyCoordinate.shared.isFirstLoadLocation {
            MyCoordinate.shared.isFirstLoadLocation = true
        }
        
        let mapCoor = NMGLatLng(lat: DefaultCoordinate.lat.rawValue, lng: DefaultCoordinate.lng.rawValue)
        
        viewController?.ifDeniedLocation(mapCoor)
    }
}
