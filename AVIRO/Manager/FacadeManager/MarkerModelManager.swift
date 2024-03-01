//
//  MarkerModelManager.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/19.
//

import NMapsMap.NMFMarker
// realm 생성 및 기타 활동을 실행할때는 동일 쓰레드에서 진행해야함
import RealmSwift

protocol MarkerModelManagerProtocol {
    func fetchRawData(completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void)
    func updateRawDataWhenViewWillAppear(
        completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void
    )
    
    func setAllMarkerModels(with markers: [MarkerModel])
    func getAllMarkers() -> [NMFMarker]
    func getAllMarkerModel() -> [MarkerModel]
    
    func getUpdatedMarkers() -> [NMFMarker]
    
    func getMarkerModelFromCoordinates(lat: Double, lng: Double) -> (MarkerModel?, Int?)
    func getMarkerModelFromMarker(with marker: NMFMarker) -> (MarkerModel?, Int?)
    func getMarkerModelFromSerachModel(with searchModel: MatchedPlaceModel) -> (MarkerModel?, Int?)
    
    func updateMarkerModels(with marker: MarkerModel)
    func updateSelectedMarkerModel(index: Int, model: MarkerModel)
    
    func updateMarkerModelWhenClicked(with markerModel: MarkerModel)
    func updateMarkerModelWhenOnStarButton(isTapped: Bool, markerModel: [MarkerModel]?)
    
    func deleteAllMarker()
}

final class MarkerModelManager: MarkerModelManagerProtocol {
    private let markerModelCache: MarkerModelCacheProtocol
    
    private var updateTime: String {
        get {
            return UserDefaults.standard.string(forKey: UDKey.timeForUpdate.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UDKey.timeForUpdate.rawValue)
        }
    }
    
    init(markerModelCache: MarkerModelCacheProtocol = MarkerModelCache.shared ) {
        self.markerModelCache = markerModelCache
    }
    
    // MARK: fetch All Data
    /// local에 데이터가 없다면, server에서 모든 데이터 로드 후 저장
    /// 그 후 업데이트 된 내용만 local에 저장
    func fetchRawData(
        completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void
    ) {
        // realm 마이그레이션 실행
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // oldScehemaVersion이 현재 스키마 버전보다 낮은 경우 마이그레이션을 수행
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: MarkerModelFromRealm.className()) { _, newObject in
                        // 새로운 프로퍼티에 대한 기본값 설정
                        newObject?["title"] = ""
                        newObject?["category"] = ""
                    }
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        print("realm 위치: ", Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
        let haveStoredData = realm.objects(MarkerModelFromRealm.self).count > 0 ? true : false
        let hasTitleInRealm = realm.objects(MarkerModelFromRealm.self).filter("title != ''").count > 0 ? true : false

        if haveStoredData && hasTitleInRealm {
            fetchRawDataFromRealm(completionHandler: completionHandler)
        } else {
            fetchRawDataFromServer(completionHandler: completionHandler)
        }
    }
    
    private func fetchRawDataFromRealm(
        completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void
    ) {
        let mapModel = AVIROMapModelDTO(
            longitude: "0.0",
            latitude: "0.0",
            wide: "0.0",
            time: updateTime
        )
        
        AVIROAPI.manager.loadNerbyPlaceModels(with: mapModel) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    let realm = try! Realm()
                    if let updatePlace = success.data.updatedPlace {
                        for model in updatePlace {
                            let realmModel = MarkerModelFromRealm(
                                placeId: model.placeId,
                                latitude: model.y,
                                longitude: model.x,
                                title: model.title,
                                category: model.category,
                                isAll: model.allVegan,
                                isSome: model.someMenuVegan,
                                isRequest: model.ifRequestVegan
                            )
                            
                            try! realm.write {
                                realm.add(realmModel, update: .modified)
                            }
                        }
                    }
                    
                    if let deletedPlace = success.data.deletedPlace {
                        for placeId in deletedPlace {
                            if let toDeleted = realm.object(
                                ofType: MarkerModelFromRealm.self,
                                forPrimaryKey: placeId) {
                                try! realm.write {
                                    realm.delete(toDeleted)
                                }
                            }
                        }
                    }
                    let updatedDataRaw = realm.objects(MarkerModelFromRealm.self)
                    let updatedDataArray = Array(updatedDataRaw).map { $0.toAVIROMarkerModel() }
                    
                    self?.updateTime = TimeUtility.nowDateAndTime()
                    completionHandler(.success(updatedDataArray))
                } else {
                    completionHandler(.failure(.badRequest))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func fetchRawDataFromServer(
        completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void
    ) {
        updateTime = TimeUtility.nowDateAndTime()
        
        let model = AVIROMapModelDTO(
            longitude: "0.0",
            latitude: "0.0",
            wide: "0.0",
            time: nil
        )
        
        AVIROAPI.manager.loadNerbyPlaceModels(with: model) { result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    if let models = success.data.updatedPlace {
                        let realmModels = models.map { model -> MarkerModelFromRealm in
                            return MarkerModelFromRealm(
                                placeId: model.placeId,
                                latitude: model.y,
                                longitude: model.x,
                                title: model.title,
                                category: model.category,
                                isAll: model.allVegan,
                                isSome: model.someMenuVegan,
                                isRequest: model.ifRequestVegan)
                        }
                        
                        let realm = try! Realm()
                        
                        try! realm.write {
                            realm.add(realmModels, update: .modified)
                        }
                        
                        completionHandler(.success(models))
                    }
                } else {
                    completionHandler(.failure(.badRequest))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: All Marker Models cache 저장
    /// 가공된 데이터 싱글턴 패턴에 저장
    func setAllMarkerModels(with markers: [MarkerModel]) {
        markerModelCache.setMarkerModel(markers)
    }
    
    // MARK: Get All Markers
    /// 가공된 데이터에서 Marer만 불러오기
    func getAllMarkers() -> [NMFMarker] {
        markerModelCache.getMarkers()
    }
    
    func getAllMarkerModel() -> [MarkerModel] {
        markerModelCache.getMarkerModels()
    }
    
    // MARK: updateMarkerModelsWhenViewWillAppear
    /// 앱이 실행 중일때 marker데이터 업데이트 하는 경우
    func updateRawDataWhenViewWillAppear(
        completionHandler: @escaping (Result<[AVIROMarkerModel], APIError>) -> Void
    ) {
        let mapModel = AVIROMapModelDTO(
            longitude: MyCoordinate.shared.longitudeString,
            latitude: MyCoordinate.shared.latitudeString,
            wide: "0.0",
            time: updateTime
        )
        
        AVIROAPI.manager.loadNerbyPlaceModels(with: mapModel) { [weak self] result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    let realm = try! Realm()
                    
                    var updatedModels: [AVIROMarkerModel] = []
                    
                    if let updatePlace = success.data.updatedPlace {
                        
                        for model in updatePlace {
                            let realmModel = MarkerModelFromRealm(
                                placeId: model.placeId,
                                latitude: model.y,
                                longitude: model.x,
                                title: model.title,
                                category: model.category,
                                isAll: model.allVegan,
                                isSome: model.someMenuVegan,
                                isRequest: model.ifRequestVegan
                            )
                            
                            try! realm.write {
                                realm.add(realmModel, update: .modified)
                            }
                            
                            let markerModel = realmModel.toAVIROMarkerModel()
                            updatedModels.append(markerModel)
                        }
                    }
                    
                    if let deletedPlace = success.data.deletedPlace {
                        var deletedModels: [String] = []
                        
                        for placeId in deletedPlace {
                            if let toDeleted = realm.object(
                                ofType: MarkerModelFromRealm.self,
                                forPrimaryKey: placeId) {
                                try! realm.write {
                                    realm.delete(toDeleted)
                                }
                                
                                deletedModels.append(placeId)
                                self?.markerModelCache.deleteMarkerModel(with: placeId)
                            }
                        }
                    }
                    self?.updateTime = TimeUtility.nowDateAndTime()
                    completionHandler(.success(updatedModels))
                } else {
                    completionHandler(.failure(.badRequest))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: Update MarkerModels
    /// 앱 새로고침 후 업데이트 Raw Data를 가공 후 Cache에 데이터 넣기
    func updateMarkerModels(with marker: MarkerModel) {
        markerModelCache.updateMarkerModel(marker)
    }
    
    // MARK: Update Selected MarkerModel
    func updateSelectedMarkerModel(index: Int, model: MarkerModel) {
        markerModelCache.updateMarkerModel(index, model)
    }
    
    // MARK: Updated된 마커 데이터 불러오기
    func getUpdatedMarkers() -> [NMFMarker] {
        markerModelCache.getUpdatedMarkers()
    }
    
    // MARK: MarkerModel 불러오기
    /// 좌표를 통해서 Marker 데이터 불러오기
    func getMarkerModelFromCoordinates(lat: Double, lng: Double) -> (MarkerModel?, Int?) {
        let (markerModel, index) = markerModelCache.getMarker(x: lat, y: lng)
        
        return (markerModel, index)
    }
    
    func getMarkerModelFromMarker(with marker: NMFMarker) -> (MarkerModel?, Int?) {
        let (markerModel, index) = markerModelCache.getMarker(with: marker)
        
        return (markerModel, index)
    }
    
    func getMarkerModelFromSerachModel(with searchModel: MatchedPlaceModel) -> (MarkerModel?, Int?) {
        let (markerModel, index) = markerModelCache.getMarker(with: searchModel)
        
        return (markerModel, index)
    }
    
    func updateMarkerModelWhenClicked(with markerModel: MarkerModel) {
        markerModelCache.updateMarkerModelWhenClicked(with: markerModel)
    }
    
    func updateMarkerModelWhenOnStarButton(isTapped: Bool, markerModel: [MarkerModel]? = nil) {
        if isTapped {
            if let markerModel = markerModel {
                markerModelCache.updateWhenStarButton(markerModel)
            }
        } else {
            markerModelCache.resetAllStarMarkers()
        }
    }
    
    // MARK: Delete All Marker
    func deleteAllMarker() {
        let realm = try! Realm()
        
        try! realm.write {
            let allMarkers = realm.objects(MarkerModelFromRealm.self)
            realm.delete(allMarkers)
        }
        
        markerModelCache.deleteAllMarkerModel()
    }
}
