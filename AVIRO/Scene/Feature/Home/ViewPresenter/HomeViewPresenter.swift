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
    func afterLoadStarButton(showMarkers: [NMFMarker], hideMarkers: [NMFMarker])
    
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
    
    // MARK: - 24.02.17 2.0 Icon Update - ViewModel Refectoring 전 임시 업데이트
    func deleteCancelButtonFromCategoryCollection()
    func deleteCancelButtonWhenAllCategoryFalse()
    func updateCancelButtonFromCategoryCollection()
    
    func afterClickedCategoryModel(showMarkers: [NMFMarker], hideMarkers: [NMFMarker])
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
    
    private var isStarButtonSelected: Bool = false
    private var selectedCategory: [CategoryType] = []
    private var showMarkerWhenClickedCategory: [MarkerModel] = []
    private var hideMarkerWhenClickedCategory: [MarkerModel] = []
    
    // type / selected , cancel / hidden
    var categoryType = [
        ("식당", false),
        ("카페", false),
        ("술집", false),
        ("빵집", false)
    ]
    
    // TODO: - 문서화 & 리팩토링 필요
    var whenCategoryUpdateType = ("", false) {
        didSet {
            if whenCategoryUpdateType.0 == "취소" {
                for index in 1..<categoryType.count {
                    categoryType[index].1 = false
                }
                categoryType.remove(at: 0)
                viewController?.deleteCancelButtonFromCategoryCollection()
                
                afterCategoryChangedLoadAllMarkers()
            } else {
                let shouldInsertCancel = self.categoryType.firstIndex(where: { $0.0 == "취소" }) == nil
                if shouldInsertCancel {
                    categoryType.insert(("취소", false), at: 0)
                    viewController?.updateCancelButtonFromCategoryCollection()
                }
                
                if let updatedIndex = categoryType.firstIndex(where: { $0.0 == whenCategoryUpdateType.0 }) {
                    categoryType[updatedIndex].1.toggle()
                }
                
                if !categoryType.contains(where: { $0.1 == true }) {
                    categoryType.remove(at: 0)
                    viewController?.deleteCancelButtonWhenAllCategoryFalse()
                    
                    afterCategoryChangedLoadAllMarkers()
                } else {
                    whenAfterCategoryButtonTapped(with: whenCategoryUpdateType.0, state: whenCategoryUpdateType.1)
                }
            }
        }
    }
    
    var afterGetPlaceSummaryModel: (() -> Void)?
    var afterGetPlaceDetailModel: (() -> Void)?
    
    private func afterCategoryChangedLoadAllMarkers() {
        selectedCategory = []
        showMarkerWhenClickedCategory = []
        hideMarkerWhenClickedCategory = []
        
        let markers = markerModelManager.getAllMarkers()
        
        if !isStarButtonSelected {
            self.viewController?.loadMarkers(with: markers)
        }
    }
    
    init(viewController: HomeViewProtocol,
         markerManager: MarkerModelManagerProtocol = MarkerModelManager(),
         bookmarkManager: BookmarkFacadeProtocol = BookmarkFacadeManager(),
         amplitude: AmplitudeProtocol = AmplitudeUtility.shared
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
        viewController?.setupAttribute()
        viewController?.setupGesture()
        viewController?.setupLayout()
        
        locationManager.delegate = self
        
        UserCoordinate.shared.afterFirstLoadLocation = { [weak self] in
            self?.loadVeganData()
        }
            
        setNotification()
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

        for (index, data) in mapData.enumerated() {
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
        
        marker.captionText = data.title
        marker.captionColor = .gray0
        marker.captionTextSize = 10
        marker.captionMinZoom = 14
        marker.captionRequestedWidth = 80
        marker.captionOffset = 3
        
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
                            category: markerModel.categoryType,
                            placeTitle: place.title,
                            placeCategory: place.category,
                            distance: distanceString,
                            reviewsCount: reviewsCount,
                            address: place.address
                        )
                        
                        self?.amplitude.placePresent(with: place.title)
                        
                        DispatchQueue.main.async {
                            let isStar = self?.bookmarkManager.checkData(with: placeId)
                            
                            self?.viewController?.afterClickedMarker(
                                placeModel: placeTopModel,
                                placeId: placeId,
                                isStar: isStar ?? false
                            )
                            
                            self?.afterGetPlaceSummaryModel?()
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
    @objc func afterMainSearchPlace(_ notification: Notification) {
        guard let checkIsInAVIRO = notification.userInfo?[NotiName.afterMainSearch.rawValue]
                as? MatchedPlaceModel,
              let index = notification.userInfo?["Index"] as? Int
        else { return }
        
        afterMainSearch(checkIsInAVIRO, searchIndex: index)
    }
    
    // MARK: After Main Search Method
    private func afterMainSearch(
        _ afterSearchModel: MatchedPlaceModel,
        searchIndex: Int
    ) {
        // AVIRO에 데이터가 없을 때
        if !afterSearchModel.allVegan && !afterSearchModel.someVegan && !afterSearchModel.requestVegan {
            viewController?.moveToCameraWhenNoAVIRO(
                afterSearchModel.x,
                afterSearchModel.y
            )
            
            amplitude.searchClickResult(
                index: searchIndex,
                keyword: afterSearchModel.title,
                placeID: nil,
                placeName: nil,
                category: nil
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
            
            amplitude.searchClickResult(
                index: searchIndex,
                keyword: afterSearchModel.title,
                placeID: markerModel.placeId,
                placeName: afterSearchModel.title,
                category: markerModel.categoryType
            )
        }
    }
    
    // MARK: PlaceId로 marker 확인
    func checkPlaceIdTest(with placeId: String) {
        let (markerModel, index) = markerModelManager.getMarkerModelFromPlaceId(with: placeId)
        
        guard let markerModel = markerModel else { return }
        guard let index = index else { return }
                                        
        selectedMarkerIndex = index
        selectedMarkerModel = markerModel
        selectedMarkerModel?.isClicked = true
                    
        hasTouchedMarkerBefore = true
        
        getPlaceSummaryModel(markerModel)

        viewController?.moveToCameraWhenHasAVIRO(markerModel, zoomTo: 14)
    }
    
    // MARK: Bookmark Load Method
    func loadBookmark(_ isSelected: Bool) {
        isStarButtonSelected = isSelected
        if isSelected {
            whenAfterLoadStarButtonTapped()
        } else {
            whenAfterLoadNotStarButtonTapped()
        }
    }
    
    // MARK: - Changed Marker From Category Method
    private func whenAfterCategoryButtonTapped(with type: String, state isActived: Bool) {
        let markersModel = self.markerModelManager.getAllMarkerModel()
        
        guard let categoryType = CategoryType(with: type) else { return }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if isActived {
                if !self.selectedCategory.contains(where: { $0 == categoryType }) {
                    self.selectedCategory.append(categoryType)
                }
            } else {
                self.selectedCategory.removeAll { $0 == categoryType }
            }
            
            self.showMarkerWhenClickedCategory = markersModel.filter { model in
                self.selectedCategory.contains(model.categoryType)
            }
            self.hideMarkerWhenClickedCategory = markersModel.filter { model in
                !self.selectedCategory.contains(model.categoryType)
            }

            let showMarkers = self.showMarkerWhenClickedCategory.map { $0.marker }
            let hideMarkers = self.hideMarkerWhenClickedCategory.map { $0.marker }
            
            DispatchQueue.main.async {
                if !self.isStarButtonSelected {
                    self.viewController?.afterClickedCategoryModel(
                        showMarkers: showMarkers,
                        hideMarkers: hideMarkers)
                }
            }
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
                
                let starMarkers = starMarkersModel.map { $0.marker }
                
                self?.viewController?.afterLoadStarButton(
                    showMarkers: starMarkers,
                    hideMarkers: noMarkers
                )
            }
        }
    }
    
    private func whenAfterLoadNotStarButtonTapped() {
        markerModelManager.updateMarkerModelWhenOnStarButton(
            isTapped: false,
            markerModel: nil
        )
        
        // MARK: - Category 클릭 중 일 때
        if selectedCategory.count > 0 {
            let showMarkers = self.showMarkerWhenClickedCategory.map { $0.marker }
            let hideMarkers = self.hideMarkerWhenClickedCategory.map { $0.marker }
            
            self.viewController?.afterClickedCategoryModel(
                showMarkers: showMarkers,
                hideMarkers: hideMarkers)
        } else {
            let markers = markerModelManager.getAllMarkers()
            
            viewController?.loadMarkers(with: markers)
        }
    }
    
    // MARK: Bookmark Upload & Delete Method
    func updateBookmark(_ isSelected: Bool) {
        guard let placeId = selectedPlaceId else { return }
        
        let placeIds = [placeId]
        
        if isSelected {
            bookmarkManager.updateData(with: placeIds) { [weak self] error in
                self?.viewController?.showToastAlert(error)
            }
        } else {
            bookmarkManager.deleteData(with: placeIds) { [weak self] error in
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
            
            self?.afterGetPlaceDetailModel?()
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
                    if success.data?.reported ?? false {
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
        
        amplitude.menuEdit(
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
                if model.statusCode == 200 {
                    if let successMessage = model.message {
                        self?.viewController?.showToastAlert(successMessage)
                    } else {
                        self?.viewController?.showToastAlert("귀중한 정보 감사합니다!")
                    }
                } else {
                    guard let errorMessage = model.message else { return }
                    self?.viewController?.showToastAlert(errorMessage)
                }
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
    
    func afterLevelUpViewCheckTapped(with level: Int) {
        amplitude.levelupDidMove(with: level)
    }
    
    func afterLevelUpViewNocheckTapped(with level: Int) {
        amplitude.levelupDidNotMove(with: level)
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
        
        UserCoordinate.shared.latitude = location.coordinate.latitude
        UserCoordinate.shared.longitude = location.coordinate.longitude

        if !UserCoordinate.shared.isFirstLoadLocation {
            UserCoordinate.shared.isFirstLoadLocation = true
        }
        
        locationManager.stopUpdatingLocation()
        
        viewController?.isSuccessLocation()
    }
    
    private func ifDeniedLocation() {
        UserCoordinate.shared.latitude = DefaultCoordinate.lat.rawValue
        UserCoordinate.shared.longitude = DefaultCoordinate.lng.rawValue

        if !UserCoordinate.shared.isFirstLoadLocation {
            UserCoordinate.shared.isFirstLoadLocation = true
        }
        
        let mapCoor = NMGLatLng(lat: DefaultCoordinate.lat.rawValue, lng: DefaultCoordinate.lng.rawValue)
        
        viewController?.ifDeniedLocation(mapCoor)
    }
}
