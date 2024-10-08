//
//  EditPlaceInfoPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/25.
//

import UIKit

import NMapsMap

protocol EditPlaceInfoProtocol: NSObject {
    func setupLayout()
    func setupAttribute()
    func setupGesture()
    func handleClosure()
    func whenViewWillAppearSelectedIndex(_ index: Int)
    func isDetailFieldCheckBeforeKeyboardShowAndHide(
        notification: NSNotification
    ) -> Bool
    func keyboardWillShow(height: CGFloat)
    func keyboardWillHide()
    func dataBindingLocation(
        title: String,
        category: String,
        marker: NMFMarker,
        address: String,
        address2: String
    )
    func dataBindingPhone(phone: String)
    func dataBindingOperatingHours(
        operatingHourModels: [EditOperationHoursModel]
    )
    func dataBindingHomepage(homepage: String)
    func pushAddressEditViewController(
        placeMarkerModel: MarkerModel
    )
    func updateNaverMap(_ latLng: NMGLatLng)
    func editStoreButtonChangeableState(_ state: Bool)
    func popViewController()
    func showErrorAlert(with error: String, title: String?)
}

final class EditPlaceInfoPresenter {
    weak var viewController: EditPlaceInfoProtocol?
    
    private let amplitude: AmplitudeProtocol
    
    private var selectedIndex: Int!
    private var placeId: String?
    private var placeMarkerModel: MarkerModel?
    private var placeSummary: AVIROPlaceSummary?
    private var placeInfo: AVIROPlaceInfo?
    private var placeOperationModels: [EditOperationHoursModel]?
    
    private var newMarker = NMFMarker()
    
    private var canChange = false
    
    private var editedTypes = Set<PlaceInfoEditType>()
    
    var afterChangedTitle = "" {
        didSet {
            checkIsChangedTitle()
        }
    }
    private var isChangedTitle = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    var afterChangedCategory = PlaceCategory.restaurant {
        didSet {
            checkIsChangedCategory()
        }
    }
    private var isChangedCategory = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    var isChangedFromPublicAddress = true
    var locationFromMapView = NMGLatLng()
    
    var afterChangedAddress = "" {
        didSet {
            changedMarkerLocation()
            checkIsChangedAddress()
        }
    }
    
    private var isChangedAddress = false {
        didSet {
            changeEditButtonState()
        }
    }
    private var afterChangedXLng = ""
    private var afterChangedYLat = ""
    
    var afterChangedAddressDetail = "" {
        didSet {
            checkIsChangedAddressDetail()
        }
    }
    private var isChangedAddressDetail = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    var afterChangedPhone = "" {
        didSet {
            checkIsChangedPhone()
        }
    }
    private var isChangedPhone = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    private var afterChangedOperationHourArray = [EditOperationHoursModel]()
    var afterChangedOperationHour = EditOperationHoursModel(
        day: Day.mon,
        operatingHours: "",
        breakTime: "",
        isToday: false
    ) {
        didSet {
            checkIsChangedOperationHour()
        }
    }
    private var isChangedOperationHour = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    var afterChangedURL = "" {
        didSet {
            checkIsChangedURL()
        }
    }
    
    private var isChangedURL = false {
        didSet {
            changeEditButtonState()
        }
    }
    
    var afterReportShowAlert: (() -> Void)?
    
    init(viewController: EditPlaceInfoProtocol,
         amplitude: AmplitudeProtocol = AmplitudeUtility.shared,
         placeMarkerModel: MarkerModel? = nil,
         placeId: String? = nil,
         placeSummary: AVIROPlaceSummary? = nil,
         placeInfo: AVIROPlaceInfo? = nil,
         selectedIndex: Int = 0
    ) {
        self.viewController = viewController
        self.amplitude = amplitude
        
        self.selectedIndex = selectedIndex
        self.placeMarkerModel = placeMarkerModel
        self.placeId = placeId
        self.placeSummary = placeSummary
        self.placeInfo = placeInfo
        
        self.afterChangedXLng = String(placeMarkerModel?.marker.position.lng ?? 0.0)
        self.afterChangedYLat = String(placeMarkerModel?.marker.position.lat ?? 0.0)
    }
    
    func viewDidLoad() {
        viewController?.setupLayout()
        viewController?.setupAttribute()
        viewController?.setupGesture()
        viewController?.handleClosure()
        
        dataBinding()
    }
    
    func viewWillAppear() {
        viewController?.whenViewWillAppearSelectedIndex(selectedIndex)
        
        addKeyboardNotification()
    }
    
    func viewWillDisappear() {
        selectedIndex = 0
        removeKeyboardNotification()
    }
    
    // MARK: Keyboard에 따른 view 높이 변경 Notification
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(
        notification: NSNotification
    ) {
        guard let viewController = viewController else { return }
        
        if viewController.isDetailFieldCheckBeforeKeyboardShowAndHide(
            notification: notification
        ) {
            if let keyboardFrame: NSValue = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                viewController.keyboardWillShow(
                    height: keyboardRectangle.height
                )
            }
        }
    }
    
    @objc private func keyboardWillHide(
        notification: NSNotification) {
            guard let viewController = viewController else { return }
            
            if viewController.isDetailFieldCheckBeforeKeyboardShowAndHide(
                notification: notification
            ) {
                viewController.keyboardWillHide()
            }
        }
    
    // MARK: Data Binding
    private func dataBinding() {
        dataBindingLocation()
        dataBindingPhone()
        dataBindingWorkingHours()
        dataBindingHomepage()
    }
    
    private func dataBindingLocation() {
        guard let placeSummary = placeSummary,
              let placeMarkerModel = placeMarkerModel,
              let placeInfo = placeInfo
        else { return }
        
        let title = placeSummary.title
        let category = placeSummary.category
        let address = placeInfo.address
        let address2 = placeInfo.address2 ?? ""
        
        let markerPosition = placeMarkerModel.marker.position
        let markerImage = placeMarkerModel.marker.iconImage
        
        newMarker.position = markerPosition
        newMarker.iconImage = markerImage
        
        viewController?.dataBindingLocation(
            title: title,
            category: category,
            marker: newMarker,
            address: address,
            address2: address2
        )
    }
    
    private func dataBindingPhone() {
        guard let placeInfo = placeInfo,
              let phone = placeInfo.phone
        else { return }
        
        viewController?.dataBindingPhone(phone: phone)
    }
    
    private func dataBindingWorkingHours() {
        guard let placeId = placeId else { return }
        
        self.placeOperationModels = [EditOperationHoursModel]()
        
        AVIROAPI.manager.loadOperationHours(with: placeId) { [weak self] result in
            switch result {
            case .success(let model):
                if model.statusCode == 200 {
                    if let data = model.data {
                        let modelArray = data.toEditOperationHoursModels()
                        
                        self?.placeOperationModels = modelArray
                        self?.viewController?.dataBindingOperatingHours(operatingHourModels: modelArray)
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
    
    private func dataBindingHomepage() {
        guard let placeInfo = placeInfo,
              let homepage = placeInfo.url
        else { return }
        
        viewController?.dataBindingHomepage(homepage: homepage)
    }
    
    func pushAddressEditViewController() {
        guard let placeMarkerModel = placeMarkerModel else { return }
        
        viewController?.pushAddressEditViewController(
            placeMarkerModel: placeMarkerModel
        )
    }
    
    private func changedMarkerLocation() {
        if isChangedFromPublicAddress {
            changeLocationFromKakaoAPI()
        } else {
            changeLocationFromMapView()
        }
    }
    
    private func changeLocationFromKakaoAPI() {
        KakaoAPI.manager.addressSearch(with: afterChangedAddress) { [weak self] result in
            switch result {
            case .success(let model):
                guard let documents = model.documents,
                      documents.count > 0 else { return }
                
                let firstCoordinate = documents[0]
                
                if let x = firstCoordinate.x,
                   let y = firstCoordinate.y {
                    DispatchQueue.main.async {
                        self?.afterChangedXLng = x
                        self?.afterChangedYLat = y
                        
                        self?.changedMarker(lat: y, lng: x)
                    }
                    
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    self?.viewController?.showErrorAlert(with: error, title: nil)
                }
            }
        }
    }
    
    private func changeLocationFromMapView() {
        afterChangedXLng = locationFromMapView.lng.description
        afterChangedYLat = locationFromMapView.lat.description
        
        changedMarker(
            lat: locationFromMapView.lat.description,
            lng: locationFromMapView.lng.description
        )
    }
    
    // MARK: 버그 확인 main.async 해야 하나?
    private func changedMarker(
        lat: String,
        lng: String
    ) {
        guard let lat = Double(lat),
              let lng = Double(lng) else { return }
        
        let latLng = NMGLatLng(lat: lat, lng: lng)
        
        newMarker.position = latLng
        
        viewController?.updateNaverMap(latLng)
    }
}

// MARK: Data State Management Method
extension EditPlaceInfoPresenter {
    private func changeEditButtonState() {
        if isChangedTitle
            ||
            isChangedCategory
            ||
            isChangedAddress
            ||
            isChangedAddressDetail
            ||
            isChangedPhone
            ||
            isChangedOperationHour
            ||
            isChangedURL {
            viewController?.editStoreButtonChangeableState(true)
        } else {
            viewController?.editStoreButtonChangeableState(false)
        }
    }
    
    private func checkIsChangedTitle() {
        if afterChangedTitle != placeSummary?.title {
            isChangedTitle = true
        } else {
            isChangedTitle = false
        }
    }
    
    private func checkIsChangedCategory() {
        if afterChangedCategory.title != placeSummary?.category {
            isChangedCategory = true
        } else {
            isChangedCategory = false
        }
    }
    
    private func checkIsChangedAddress() {
        if afterChangedAddress != placeInfo?.address || checkCoordinate() {
            isChangedAddress = true
        } else {
            isChangedCategory = false
        }
    }
    
    private func checkCoordinate() -> Bool {
        let beforeX = String(placeMarkerModel?.marker.position.lng ?? 0.0)
        let beforeY = String(placeMarkerModel?.marker.position.lat ?? 0.0)
        
        if beforeX != afterChangedXLng || beforeY != afterChangedYLat {
            return true
        } else {
            return false
        }
    }
    
    private func checkIsChangedAddressDetail() {
        if afterChangedAddressDetail != placeInfo?.address2 ?? "" {
            isChangedAddressDetail = true
        } else {
            isChangedAddressDetail = false
        }
    }
    
    private func checkIsChangedPhone() {
        if afterChangedPhone != placeInfo?.phone ?? "" {
            isChangedPhone = true
        } else {
            isChangedPhone = false
        }
    }
    
    private func checkIsChangedOperationHour() {
        placeOperationModels?.forEach {
            if $0.day == afterChangedOperationHour.day {
                if $0.breakTime != afterChangedOperationHour.breakTime
                    ||
                    $0.operatingHours != afterChangedOperationHour.operatingHours {
                    appendToOperationArrayWhenChangedOperationHour(
                        afterChangedOperationHour
                    )
                } else {
                    compareToAfterOperationArrayFromBeforeOperationArray(
                        afterChangedOperationHour
                    )
                }
            }
        }
    }
    
    private func appendToOperationArrayWhenChangedOperationHour(
        _ model: EditOperationHoursModel
    ) {
        if let index = afterChangedOperationHourArray
            .firstIndex(where: {$0.day == model.day}
            ) {
            afterChangedOperationHourArray[index]
                .operatingHours = model.operatingHours
            afterChangedOperationHourArray[index]
                .breakTime = model.breakTime
        } else {
            afterChangedOperationHourArray.append(model)
        }
        
        isChangedOperationHour = true
    }
    
    private func compareToAfterOperationArrayFromBeforeOperationArray(
        _ model: EditOperationHoursModel
    ) {
        if let index = afterChangedOperationHourArray
            .firstIndex(where: {$0.day == model.day}
            ) {
            afterChangedOperationHourArray
                .remove(at: index)
        }
        
        if afterChangedOperationHourArray.count == 0 {
            isChangedOperationHour = false
        } else {
            isChangedOperationHour = true
        }
    }
    
    private func checkIsChangedURL() {
        if afterChangedURL != placeInfo?.url ?? "" {
            isChangedURL = true
        } else {
            isChangedURL = false
        }
    }
}

// MARK: Data Edit Request Method
extension EditPlaceInfoPresenter {
    func afterEditButtonTapped() {
        guard let placeId = placeId,
              let placeTitle = placeSummary?.title
        else { return }
        
        let userId = MyData.my.id
        let nickName = MyData.my.nickname
        
        let dispatchGroup = DispatchGroup()
        
        requestEditLocation(
            placeId: placeId,
            placeTitle: placeTitle,
            userId: userId,
            nickName: nickName,
            dispatchGroup: dispatchGroup
        )
        
        requestEditPhone(
            placeId: placeId,
            placeTitle: placeTitle,
            userId: userId,
            nickName: nickName,
            dispatchGroup: dispatchGroup
        )
        
        requestEditOperationHour(
            placeId: placeId,
            userId: userId,
            dispatchGroup: dispatchGroup
        )
        
        requestEditURL(
            placeId: placeId,
            placeTitle: placeTitle,
            userId: userId,
            nickName: nickName,
            dispatchGroup: dispatchGroup
        )
        
        dispatchGroup.notify(queue: .main
        ) { [weak self] in
            if self?.canChange ?? false {
                self?.afterEditPlaceInfo()
                self?.viewController?.popViewController()
                self?.afterReportShowAlert?()
            } else {
                
            }
        }
    }
    
    private func requestEditLocation(
        placeId: String,
        placeTitle: String,
        userId: String,
        nickName: String,
        dispatchGroup: DispatchGroup
    ) {
        if isChangedTitle
            ||
            isChangedCategory
            ||
            isChangedAddress
            ||
            isChangedAddressDetail {
            guard  let beforeCategory = placeSummary?.category,
                   let beforeAddress = placeInfo?.address
            else { return }
            
            let beforeAdderss2 = placeInfo?.address2 ?? ""
            
            dispatchGroup.enter()
            
            let model = AVIROEditLocationDTO(
                placeId: placeId,
                userId: userId,
                nickname: nickName,
                title: placeTitle,
                changedTitle: isChangedTitle ?
                AVIROEditCommonBeforeAfterDTO(
                    before: placeTitle,
                    after: afterChangedTitle
                )
                :
                    nil,
                category: isChangedCategory ?
                AVIROEditCommonBeforeAfterDTO(
                    before: beforeCategory,
                    after: afterChangedCategory.title
                )
                :
                    nil,
                address: whenRequestAndLoadAddressBasedOnCondition(
                    beforeAddress: beforeAddress
                ),
                address2: whenRequestAndLoadDetailAddressBasedOnCondition(
                    beforeDetailAddress: beforeAdderss2
                ),
                x: whenRequestAndLoadXLongitude(beforeAddress: beforeAddress),
                y: whenRequestAndLoadYLatitude(beforeAddress: beforeAddress)
            )
            
            AVIROAPI.manager.editPlaceLocation(with: model) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let success):
                    if success.statusCode != 200 {
                        self?.canChange = false
                        if let message = success.message {
                            self?.viewController?.showErrorAlert(with: message, title: "가게정보 에러")
                        }
                    } else {
                        self?.canChange = true
                    }
                case .failure(let error):
                    self?.canChange = false
                    if let error = error.errorDescription {
                        self?.viewController?.showErrorAlert(with: error, title: "가게정보 에러")
                    }
                }
            }
        }
    }
    
    private func whenRequestAndLoadAddressBasedOnCondition(
        beforeAddress: String
    ) -> AVIROEditCommonBeforeAfterDTO? {
        if (isChangedAddress || isChangedAddressDetail)
            &&
            (afterChangedAddress != "" && afterChangedAddress != beforeAddress) {
            return AVIROEditCommonBeforeAfterDTO(
                before: beforeAddress,
                after: afterChangedAddress
            )
        } else if
            (isChangedAddress || isChangedAddressDetail)
                &&
                (afterChangedAddress == "" || afterChangedAddress == beforeAddress) {
            return AVIROEditCommonBeforeAfterDTO(
                before: beforeAddress,
                after: beforeAddress
            )
        } else {
            return nil
        }
    }
    
    private func whenRequestAndLoadDetailAddressBasedOnCondition(
        beforeDetailAddress: String
    ) -> AVIROEditCommonBeforeAfterDTO? {
        if (isChangedAddress || isChangedAddressDetail)
            &&
            (
                afterChangedAddressDetail != beforeDetailAddress
            ) {
            return AVIROEditCommonBeforeAfterDTO(
                before: beforeDetailAddress,
                after: afterChangedAddressDetail
            )
        } else if
            (isChangedAddress || isChangedAddressDetail)
                &&
                (
                    afterChangedAddressDetail == beforeDetailAddress
                ) {
            return AVIROEditCommonBeforeAfterDTO(
                before: beforeDetailAddress,
                after: beforeDetailAddress
            )
        } else {
            return nil
        }
    }
    
    private func whenRequestAndLoadXLongitude(
        beforeAddress: String
    ) -> AVIROEditCommonBeforeAfterDTO? {
        let beforeX = String(placeMarkerModel?.marker.position.lng ?? 0.0)
        
        if isChangedAddress {
            return AVIROEditCommonBeforeAfterDTO(before: beforeX, after: afterChangedXLng)
        } else if isChangedAddressDetail {
            return AVIROEditCommonBeforeAfterDTO(before: beforeX, after: beforeX)
        } else {
            return nil
        }
    }
    
    private func whenRequestAndLoadYLatitude(
        beforeAddress: String
    ) -> AVIROEditCommonBeforeAfterDTO? {
        let beforeY = String(placeMarkerModel?.marker.position.lat ?? 0.0)
        
        if isChangedAddress {
            return AVIROEditCommonBeforeAfterDTO(before: beforeY, after: afterChangedYLat)
        } else if isChangedAddressDetail {
            return AVIROEditCommonBeforeAfterDTO(before: beforeY, after: beforeY)
        } else {
            return nil
        }
    }
    
    private func requestEditPhone(
        placeId: String,
        placeTitle: String,
        userId: String,
        nickName: String,
        dispatchGroup: DispatchGroup
    ) {
        if isChangedPhone {
            
            dispatchGroup.enter()
            
            let beforePhone = placeInfo?.phone ?? ""
            
            let model = AVIROEditPhoneDTO(
                placeId: placeId,
                userId: userId,
                nickname: nickName,
                title: placeTitle,
                phone: AVIROEditCommonBeforeAfterDTO(
                    before: beforePhone,
                    after: afterChangedPhone
                )
            )
            
            AVIROAPI.manager.editPlacePhone(with: model) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let success):
                    if success.statusCode != 200 {
                        self?.canChange = false
                        if let message = success.message {
                            self?.viewController?.showErrorAlert(with: message, title: "전화번호 에러")
                        }
                    } else {
                        self?.canChange = true
                    }
                case .failure(let error):
                    self?.canChange = false
                    
                    if let error = error.errorDescription {
                        self?.viewController?.showErrorAlert(with: error, title: "전화번호 에러")
                    }
                }
            }
        }
    }
    
    private func requestEditOperationHour(
        placeId: String,
        userId: String,
        dispatchGroup: DispatchGroup
    ) {
        if isChangedOperationHour {
            
            dispatchGroup.enter()
            
            var operationHours: [Day: EditOperationHoursModel] = [:]
            
            afterChangedOperationHourArray.forEach {
                operationHours[$0.day] = EditOperationHoursModel(
                    day: $0.day,
                    operatingHours: $0.operatingHours,
                    breakTime: $0.breakTime,
                    isToday: $0.isToday
                )
            }
            
            let model = AVIROEditOperationTimeDTO(
                placeId: placeId,
                userId: userId,
                mon: operationHours[.mon]?.operatingHours,
                monBreak: operationHours[.mon]?.breakTime,
                tue: operationHours[.tue]?.operatingHours,
                tueBreak: operationHours[.tue]?.breakTime,
                wed: operationHours[.wed]?.operatingHours,
                wedBreak: operationHours[.wed]?.breakTime,
                thu: operationHours[.thu]?.operatingHours,
                thuBreak: operationHours[.thu]?.breakTime,
                fri: operationHours[.fri]?.operatingHours,
                friBreak: operationHours[.fri]?.breakTime,
                sat: operationHours[.sat]?.operatingHours,
                satBreak: operationHours[.sat]?.breakTime,
                sun: operationHours[.sun]?.operatingHours,
                sunBreak: operationHours[.sun]?.breakTime
            )
            
            AVIROAPI.manager.editPlaceOperation(with: model) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let success):
                    if success.statusCode != 200 {
                        self?.canChange = false
                        if let message = success.message {
                            self?.viewController?.showErrorAlert(with: message, title: "영업시간 에러")
                        }
                    } else {
                        self?.canChange = true
                    }
                case .failure(let error):
                    self?.canChange = false
                    if let error = error.errorDescription {
                        self?.viewController?.showErrorAlert(with: error, title: "영업시간 에러")
                    }
                }
            }
        }
    }
    
    private func requestEditURL(
        placeId: String,
        placeTitle: String,
        userId: String,
        nickName: String,
        dispatchGroup: DispatchGroup
    ) {
        if isChangedURL {
            dispatchGroup.enter()
            
            let beforeURL = placeInfo?.url ?? ""
            
            let model = AVIROEditURLDTO(
                placeId: placeId,
                userId: userId,
                nickname: nickName,
                title: placeTitle,
                url: AVIROEditCommonBeforeAfterDTO(
                    before: beforeURL,
                    after: afterChangedURL
                )
            )
            
            AVIROAPI.manager.editPlaceURL(with: model) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let success):
                    if success.statusCode != 200 {
                        self?.canChange = false
                        if let message = success.message {
                            self?.viewController?.showErrorAlert(with: message, title: "홈페이지 에러")
                        }
                    } else {
                        self?.canChange = true
                    }
                case .failure(let error):
                    self?.canChange = false
                    if let error = error.errorDescription {
                        self?.viewController?.showErrorAlert(with: error, title: "홈페이지 에러")
                    }
                }
            }
        }
    }
    
    private func afterEditPlaceInfo() {
        guard let placeSummary = placeSummary,
            let placeInfo = placeInfo
        else { return }
        
        var category = ""
        var before = ""
        var after = ""
        
        if isChangedTitle {
            editedTypes.insert(.homepage)
            before += placeSummary.title + ", "
            after += afterChangedTitle + ", "
        }
        
        if isChangedCategory {
            editedTypes.insert(.homepage)

            before += placeSummary.category + ", "
            after += afterChangedCategory.title + ", "
        }
        
        if isChangedURL {
            editedTypes.insert(.homepage)
            
            before += placeInfo.url ?? "url 없음" + ", "
            after += afterChangedURL + ", "
        }
        
        if isChangedPhone {
            editedTypes.insert(.phone)
            
            before += placeInfo.phone ?? "phone number 없음" + ", "
            after += afterChangedPhone + ", "
        }
        
        if isChangedAddress || isChangedAddressDetail {
            editedTypes.insert(.address)
            
            var beforeAddress = placeInfo.address + " " + (placeInfo.address2 ?? "") + ", "
            var afterAddress = afterChangedAddress + " " + afterChangedAddressDetail + ", "
            
            before += beforeAddress
            after += afterAddress
        }
        
        if isChangedOperationHour {
            guard let placeOperationModels = placeOperationModels else { return }
            
            editedTypes.insert(.businessHours)
            
            var beforeOperation = ""
            var afterOperation = ""
            
            placeOperationModels.forEach {
                beforeOperation += $0.day.rawValue + "요일, "
                beforeOperation +=  "영업 시간: " + $0.operatingHours + ", "
                beforeOperation +=  "휴식: " + $0.breakTime + ", "
            }
            
            afterChangedOperationHourArray.forEach {
                afterOperation += $0.day.rawValue + "요일, "
                afterOperation +=  "영업 시간: " + $0.operatingHours + ", "
                afterOperation +=  "휴식: " + $0.breakTime + ", "
            }
            
            before += beforeOperation
            after += afterOperation
        }
        
        editedTypes.forEach {
            category += $0.rawValue + ", "
        }
        
        amplitude.placeCompleteEditPlace(
            category: category,
            before: before,
            after: after,
            model: placeSummary
        )
    }
}
