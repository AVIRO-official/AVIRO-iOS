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
    func makeLayout()
    func makeAttribute()
    func makeGesture()
    func makeSlideView()
    func whenViewWillAppear()
    func ifDenied()
    func requestSuccess()
    func saveCenterCoordinate()
    func moveToCameraWhenNoAVIRO(_ lng: Double, _ lat: Double)
    func moveToCameraWhenHasAVIRO(_ markerModel: MarkerModel)
    func loadMarkers()
    func afterClickedMarker(_ placeModel: PlaceTopModel)
    func dataBinding()
}

final class HomeViewPresenter: NSObject {
    weak var viewController: HomeViewProtocol?
    
    private let locationManager = CLLocationManager()
    
    var homeMapData: [HomeMapData]?
    
    private var hasTouchedMarkerBefore = false
    private var selectedMarkerIndex = 0 
    private var selectedMarkerModel: MarkerModel?
    
    private var firstLocation = true
    
    init(viewController: HomeViewProtocol) {
        self.viewController = viewController
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("checkIsInAVRIO"),
            object: nil
        )
    }
    
    func viewDidLoad() {
        locationManager.delegate = self
        
        viewController?.makeLayout()
        viewController?.makeAttribute()
        viewController?.makeGesture()
        viewController?.dataBinding()
    }
    
    func viewWillAppear() {
        viewController?.whenViewWillAppear()
        viewController?.makeSlideView()
    }
    
    func viewWillDisappear() {
        initMarkerState()
    }
    
    // MARK: vegan Data 불러오기
    func loadVeganData() {
        AVIROAPIManager().getNerbyPlaceModels(
            userId: "test",
            longitude: MyCoordinate.shared.longitudeString,
            latitude: MyCoordinate.shared.latitudeString,
            wide: "100",
            time: nil
        ) { [weak self] mapDatas in
            self?.saveMarkers(mapDatas.data.placeData)
        }
    }
    
    // MARK: Marker 상태 초기화
    func initMarkerState() {
        guard let selectedMarkerModel = selectedMarkerModel else { return }
        
        selectedMarkerModel.marker.changeIcon(selectedMarkerModel.mapPlace, false)
    }
    
    // MARK: Marker Data singleton에 저장하기
    func saveMarkers(_ mapData: [HomeMapData]) {
        mapData.forEach { data in
            let latLng = NMGLatLng(lat: data.y, lng: data.x)
            let marker = NMFMarker(position: latLng)
            let placeId = data.placeId
            var place: MapPlace
            
            if data.allVegan {
                place = MapPlace.All
            } else if data.someMenuVegan {
                place = MapPlace.Some
            } else {
                place = MapPlace.Request
            }
            
            marker.makeIcon(place)
            marker.touchHandler = { [weak self] _ in
                self?.touchedMarker(marker)
                
                return true
            }
            
            let markerModel = MarkerModel(
                placeId: placeId,
                marker: marker,
                mapPlace: place
            )
            
            MarkerModelArray.shared.setData(markerModel)
            
        }
        viewController?.loadMarkers()
    }
    
    // MARK: Marker Touched Method
    private func touchedMarker(_ marker: NMFMarker) {
        resetPreviouslyTouchedMarker()
        setMarkerToTouchedState(marker)
    }
    
    // MARK: Reset Previous Marker
   func resetPreviouslyTouchedMarker() {
       /// 최초 터치 이후 작동을 위한 분기처리
        if hasTouchedMarkerBefore {
            let markerModel = MarkerModelArray.shared.getMarkerFromIndex(selectedMarkerIndex)
            
            guard let markerModel = markerModel else { return }
            markerModel.marker.changeIcon(markerModel.mapPlace, false)
        }
    }
    
    // MARK: setMarkerToTouchedState
    /// 클릭한 마커 저장 후 viewController에 알리기
    private func setMarkerToTouchedState(_ marker: NMFMarker) {
        let (markerModel, index) = MarkerModelArray.shared.getMarkerFromMarker(marker)
        
        guard let validMarkerModel = markerModel else { return }
        
        guard let validIndex = index else { return }
        
        getPlaceModel(validMarkerModel)

        selectedMarkerIndex = validIndex
        selectedMarkerModel = validMarkerModel
        
        validMarkerModel.marker.changeIcon(validMarkerModel.mapPlace, true)

        hasTouchedMarkerBefore = true
        
        viewController?.moveToCameraWhenHasAVIRO(validMarkerModel)
    }
    
    // MARK: Get PlaceModel
    /// 클릭 된 마커 데이터 받기 위한 api 호출
    private func getPlaceModel(_ markerModel: MarkerModel) {
        let mapPlace = markerModel.mapPlace
        let placeX = markerModel.marker.position.lng
        let placeY = markerModel.marker.position.lat
        let placeId = markerModel.placeId

        //        let test = PlaceTopModel(placeState: MapPlace.Request, placeTitle: "Test", placeCategory: "식당", distance: "400", reviewsCount: "5", address: "테스트 입니다.")
//        viewController?.afterClickedMarker(test)
        AVIROAPIManager().getPlaceSummary(placeId: placeId) { summary in
            let place = summary.data

            let distanceValue = LocationUtility.distanceMyLocation(x_lng: placeX, y_lat: placeY)

            let distanceString = String(distanceValue).convertDistanceUnit()
            let reviewsCount = String(place.commentCount)

            let placeTopModel = PlaceTopModel(
                placeState: mapPlace,
                placeTitle: place.title,
                placeCategory: place.category,
                distance: distanceString,
                reviewsCount: reviewsCount,
                address: place.address)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.afterClickedMarker(placeTopModel)
            }
        }
    }
    
    // MARK: Save Center Coordinate
    func saveCenterCoordinate(_ coordinate: NMGLatLng) {
        CenterCoordinate.shared.longitude = coordinate.lng
        CenterCoordinate.shared.latitude = coordinate.lat
    }
    
    // MARK: Make Notification
    func makeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkIsInAVRIONotificaiton(_:)),
            name: NSNotification.Name("checkIsInAVRIO"),
            object: nil
        )
    }
    
    // MARK: Notification Method afterMainSearch
    @objc func checkIsInAVRIONotificaiton(_ noficiation: Notification) {
        guard let checkIsInAVIRO = noficiation.userInfo?["checkIsInAVRIO"] as? MatchedPlaceModel else { return }
        
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
            let (markerModel, index) = MarkerModelArray.shared.getMarkerWhenSearchAfter(
                afterSearchModel.x,
                afterSearchModel.y
            )
            
            guard let markerModel = markerModel else { return }
            guard let index = index else { return }
            
            markerModel.marker.changeIcon(markerModel.mapPlace, true)
            
            getPlaceModel(markerModel)
            selectedMarkerIndex = index
            selectedMarkerModel = markerModel
            hasTouchedMarkerBefore = true
            
            viewController?.moveToCameraWhenHasAVIRO(markerModel)
        }
    }
}

// MARK: user location 불러오기 관련 작업들
extension HomeViewPresenter: CLLocationManagerDelegate {
    func locationAuthorization() {
        
        switch locationManager.authorizationStatus {
        case .denied:
            viewController?.ifDenied()
            // TODO: 만약 거절했을 시 앞으로 해야할 작업
            
        case .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    // MARK: 개인 location data 불러오기 작업
    // 1. viewWillAppear 일때
    // 2. 위치 확인 데이터 누를 때
    func locationUpdate() {
        if locationManager.authorizationStatus != .authorizedAlways,
           locationManager.authorizationStatus != .authorizedWhenInUse {
            viewController?.ifDenied()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            viewController?.requestSuccess()
        }
    }
    
    // MARK: first location data 불러오기
    func firstLocationUpdate() {
        guard firstLocation else { return }
        if locationManager.authorizationStatus != .authorizedAlways,
           locationManager.authorizationStatus != .authorizedWhenInUse {
            viewController?.ifDenied()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            viewController?.requestSuccess()
        }
        
        firstLocation.toggle()
    }

    // MARK: 개인 Location Data 불러오고 나서 할 작업
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        MyCoordinate.shared.latitude = location.coordinate.latitude
        MyCoordinate.shared.longitude = location.coordinate.longitude
                
        locationManager.stopUpdatingLocation()
    }
}
