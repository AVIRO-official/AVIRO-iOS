//
//  AmplitudeUtility.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/10/10.
//

import Foundation

import AmplitudeSwift

// MARK: Amplitude
enum AMType: String {
    // Remove
    case signUp = "user_sign up"
    // Remove
    case withdrawal = "user_withdrawal"
    // Remove
    case userLogin = "user_login"
    // Remove
    case userLogout = "user_logout"
    // Move
    case placeUpload = "place_upload"
    // Move
    case reviewUpload = "review_upload"
    // Move
    case placeEdit = "place_edit"
    // Remove
    case placeSearch = "place_serach"
    // Remove
    case placePresent = "place_present"
    // Move
    case menuEdit = "menu_edit"
    
    // Move everything
    case challPresent = "chall_present"
    case placeListPresent = "placeList_present"
    case reviewListPresent = "reviewList_present"
    case bookmarkListPresent = "bookmarkList_present"
    case levelupDidMove = "level_up_didMove"
    case levelupDidNotMove = "level_up_didNotMove"
    
    case wellcomeClick = "wellcome_click"
    case wellcomeNoShow = "wellcome_noShow"
    case wellcomeClose = "wellcome_close"
}

enum AMPUserType: String {
    case signUpClick = "signup_click"
    case signupComplete = "signup_complete"
    case loginComplete = "login_complete"
    case logoutComplete = "logout_comlete"
    case withdrawalComplete = "withdrawal_Complete"
}

enum AMPBrowseType: String {
    case searchEnterTerm = "search_enter_term"
    case searchClickResult = "search_click_result"
    case bookmarkClickInPlace = "bookmark_click_in_place"
    case bookmarkClickInMap = "bookmark_click_in_map"
    case bookmarkClickList = "bookmark_click_list"
    case placeViewSheet = "place_view_sheet"
    case placeViewhalf = "place_view_half"
    case placeViewMenu = "place_view_menu"
    case placeViewReview = "place_view_review"
}

enum AMPEngage: String {
    case reviewViewUpload = "review_view_upload"
    case reviewCompleteUpload = "review_complete_upload"
    case placeViewUpload = "place_view_upload"
    case placeCompleteUpload = "place_complete_upload"
    case challengeClickCheckingLevelUp = "challenge_click_checking_levelup"
    case challengeView = "challenge_view"
    case placeClickEditPlace = "place_click_edit_place"
    case placeCompleteEditPlace = "place_complete_edit_place"
    case placeClickEditMenu = "place_click_edit_menu"
    case placeCompleteEditMenu = "place_complete_edit_menu"
    case placeClickRemove = "place_click_remove"
    case placeCompleteRemove = "place_complete_remove"
}

enum PlaceViewSheetType: String {
    case marker = "marker"
    case search = "search"
    case bookmark = "bookmark in map"
    case bookmarkList = "bookmark in challenge tab"
    case registeredPlaceList = "registered place list in challenge tab"
    case registeredReviewList = "registered review list in challenge tab"
}

enum ScolledInHomeType {
    case menu
    case review
}

enum InfoSearchType: String {
    case scrolledInHomeTab = "scroll in home tab"
    case menuTabbed = "click menu tab"
    case reviewTabbed = "click review tab"
}

enum ReviewUploadPagePathType: String {
    case home = "button in home tab"
    case review = "filed in review tab"
}

enum PlaceInfoEditType: String {
    case homepage = "homepage"
    case businessHours = "business hours"
    case address = "address"
    case phone = "phone number"
}

protocol AmplitudeProtocol {
    func signUpClick(with type: LoginType)
    func signUpComplete()
    func loginComplete()
    func logoutComplete()
    func withdrawalComplete()
    
    func searchEnterTerm(
        path: HomeSearchPath,
        number: Int,
        keyword: String
    )
    func searchClickResult(
        index: Int,
        keyword: String,
        placeID: String?,
        placeName: String?,
        category: CategoryType?
    )
    func bookmarkClickInPlace(clickedModel: AVIROPlaceSummary, bookmarks: Int)
    func bookmarkClickInMap()
    func bookmarkClickList()
    func placeViewSheet(
        path: PlaceViewSheetType,
        clickedModel: AVIROPlaceSummary,
        restaurantActive: Bool,
        cafeActive: Bool,
        barActive: Bool,
        bakeryActive: Bool
    )
    func placeViewHalf(clickedModel: AVIROPlaceSummary)
    func placeViewInfoSearched(
        type: InfoSearchType,
        scrollType: ScolledInHomeType?,
        model: AVIROPlaceSummary
    )
    
    func reviewViewUpload(
        type: ReviewUploadPagePathType,
        model: AVIROPlaceSummary
    )
    func reviewCompleteUpload(
        model: AfterWriteReviewModel,
        placeName: String,
        category: String,
        total: Int,
        isFirst: Bool
    )
    func placeViewUpload()
    func placeCompleteUpload(model: AVIROEnrollPlaceDTO, total: Int, isFirst: Bool)
    func challengeClickCheckingLevelUp(isChecked: Bool)
    func challengeView()
    func placeClickEditPlace(model: AVIROPlaceSummary)
    func placeCompleteEditPlace(category: String, before: String, after: String, model: AVIROPlaceSummary)
    func placeClickEditMenu(model: AVIROPlaceSummary)
    func placeCompleteEditMenu(
        before: Int,
        after: Int,
        model: AVIROPlaceSummary
    )
    func placeClickRemove(model: AVIROPlaceSummary)
    func placeCompleteRemove(model: AVIROPlaceSummary)
    
    func signUp(with userId: String)
    func withdrawal()
    func login()
    func logout()
    
    func placeUpload(with place: String)
    func reviewUpload(with place: String, review: String)
    
    func placePresent(with place: String)
    func placeSearch(with query: String)
    
    func placeEdit(with place: String)
    func menuEdit(
        with place: String,
        beforeMenus: [AVIROMenu],
        afterMenus: [AVIROMenu]
    )
    
    func challengePresent()
    func placeListPresent()
    func reviewListPresent()
    func bookmarkListPresent()
    
    func levelupDidMove(with level: Int)
    func levelupDidNotMove(with level: Int)
    
    func didTappedCheckWelcome()
    func didTappedNoMoreShowWelcome()
    func didTappedCloseWelcome()
}

final class AmplitudeUtility: AmplitudeProtocol {
    private init() { }
    
    static let shared = AmplitudeUtility()
    
    private var amplitude: Amplitude? {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as? AppDelegate)?.amplitude
        } else {
            var amplitudeInstance: Amplitude?
            DispatchQueue.main.sync {
                amplitudeInstance = (UIApplication.shared.delegate as? AppDelegate)?.amplitude
            }
            return amplitudeInstance
        }
    }
    
    func signUpClick(with type: LoginType) {
        let identify = Identify()
        identify.set(
            property: "auth_type",
            value: type.rawValue
        )
        
        amplitude?.identify(identify: identify)
        amplitude?.track(
            eventType: AMPUserType.signUpClick.rawValue
        )
    }
    
    func signUpComplete() {
        let date = Date().toSimpleDateString()
        let identify = Identify()
        let version = SystemUtility.appVersion ?? ""
        let type = UserDefaults.standard.string(forKey: UDKey.loginType.rawValue) ?? ""
        
        identify.set(
            property: "name",
            value: MyData.my.name
        )
        identify.set(
            property: "email",
            value: MyData.my.email
        )
        identify.set(
            property: "nickname",
            value: MyData.my.nickname
        )
        identify.set(
            property: "version",
            value: version
        )
        identify.set(
            property: "auth_type",
            value: type
        )
        identify.set(
            property: "signup_date",
            value: date
        )
        
        amplitude?.identify(identify: identify)
        
        amplitude?.track(
            eventType: AMPUserType.signupComplete.rawValue,
            eventProperties: ["signup_date": date]
        )
    }
    
    func loginComplete() {
        let date = Date().toString2()
        
        amplitude?.track(
            eventType: AMPUserType.loginComplete.rawValue,
            eventProperties: ["login_date": date]
        )
    }
    
    func logoutComplete() {
        let date = Date().toString2()
        
        amplitude?.track(
            eventType: AMPUserType.logoutComplete.rawValue,
            eventProperties: ["logout_date": date]
        )
    }
    
    func withdrawalComplete() {
        let date = Date().toSimpleDateString()
        
        amplitude?.track(
            eventType: AMPUserType.withdrawalComplete.rawValue,
            eventProperties: ["withdrawal_date": date]
        )
    }
    
    // TODO: Number 수정 필요
    // 현 코드에서는 불가능
    func searchEnterTerm(
        path: HomeSearchPath,
        number: Int,
        keyword: String
    ) {
        amplitude?.track(
            eventType: AMPBrowseType.searchEnterTerm.rawValue,
            eventProperties: [
                "search_path": path.value,
                "number": number,
                "keywords": keyword
            ]
        )
    }
    
    func searchClickResult(
        index: Int,
        keyword: String,
        placeID: String? = nil,
        placeName: String? = nil,
        category: CategoryType? = nil
    ) {
        amplitude?.track(
            eventType: AMPBrowseType.searchClickResult.rawValue,
            eventProperties: [
                "rank": index + 1,
                "keywords": keyword,
                "place_id": placeID ?? "null",
                "place_name": placeName ?? "null",
                "category": category?.title ?? "null"
            ]
        )
    }
    
    func bookmarkClickInPlace(
        clickedModel: AVIROPlaceSummary,
        bookmarks: Int
    ) {
        let identify = Identify()

        identify.set(
            property: "total_bookmark",
            value: bookmarks
        )
        
        amplitude?.identify(identify: identify)
        
        amplitude?.track(
            eventType: AMPBrowseType.bookmarkClickInPlace.rawValue,
            eventProperties: [
                "address": clickedModel.address,
                "place_id": clickedModel.placeId,
                "place_name": clickedModel.title,
                "category": clickedModel.category
            ]
        )
    }
    
    func bookmarkClickInMap() {
        amplitude?.track(
            eventType: AMPBrowseType.bookmarkClickInMap.rawValue
        )
    }
    
    func bookmarkClickList() {
        amplitude?.track(
            eventType: AMPBrowseType.bookmarkClickList.rawValue
        )
    }
    
    func placeViewSheet(
        path: PlaceViewSheetType,
        clickedModel: AVIROPlaceSummary,
        restaurantActive: Bool,
        cafeActive: Bool,
        barActive: Bool,
        bakeryActive: Bool
    ) {
        amplitude?.track(
            eventType: AMPBrowseType.placeViewSheet.rawValue,
            eventProperties: [
                "view_path_browse_place": path.rawValue,
                "place_name": clickedModel.title,
                "place_id": clickedModel.placeId,
                "category": clickedModel.category,
                "toggle_restaurant_activated": restaurantActive,
                "toggle_cafe_activated": cafeActive,
                "toggle_bar_activated" : barActive,
                "toggle_bakery_activated": bakeryActive
            ]
        )
    }
    
    func placeViewHalf(clickedModel: AVIROPlaceSummary) {
        amplitude?.track(
            eventType: AMPBrowseType.placeViewhalf.rawValue,
            eventProperties: [
                "place_name": clickedModel.title,
                "plaece_id": clickedModel.placeId,
                "category": clickedModel.category
            ]
        )
    }
    
    func placeViewInfoSearched(
        type: InfoSearchType,
        scrollType: ScolledInHomeType?,
        model: AVIROPlaceSummary
    ) {
        var eventType: String = ""
        var pathType: String = ""
        
        pathType = type.rawValue

        switch type {
        case .scrolledInHomeTab:
            switch scrollType {
            case .menu:
                eventType = AMPBrowseType.placeViewMenu.rawValue
            case .review:
                eventType = AMPBrowseType.placeViewReview.rawValue
            case nil:
                break
            }
        case .menuTabbed:
            eventType = AMPBrowseType.placeViewMenu.rawValue
        case .reviewTabbed:
            eventType = AMPBrowseType.placeViewReview.rawValue
        }
        
        amplitude?.track(
            eventType: eventType,
            eventProperties: [
                "view_path_browse_menu": pathType,
                "place_name": model.title,
                "plaece_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func reviewViewUpload(
        type: ReviewUploadPagePathType,
        model: AVIROPlaceSummary
    ) {
        amplitude?.track(
            eventType: AMPEngage.reviewViewUpload.rawValue,
            eventProperties: [
                "view_path_upload_review": type.rawValue,
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func reviewCompleteUpload(
        model: AfterWriteReviewModel,
        placeName: String,
        category: String,
        total: Int,
        isFirst: Bool
    ) {
        let identify = Identify()
        let date = Date().toSimpleDateString()
        
        identify.set(
            property: "total_reviews",
            value: total
        )
        
        if isFirst {
            identify.set(
                property: "review_date_first",
                value: date
            )
        }
        
        identify.set(
            property: "review_date_last",
            value: date
        )
        
        amplitude?.identify(identify: identify)
        
        amplitude?.track(
            eventType: AMPEngage.reviewCompleteUpload.rawValue,
            eventProperties: [
                "review": model.content,
                "review_id": model.contentId,
                "place_name": placeName,
                "place_id": model.placeId,
                "category": category
            ]
        )
    }
    
    func placeViewUpload() {
        amplitude?.track(
            eventType: AMPEngage.placeViewUpload.rawValue
        )
    }
    
    func placeCompleteUpload(
        model: AVIROEnrollPlaceDTO,
        total: Int,
        isFirst: Bool
    ) {
        let identify = Identify()
        let date = Date().toSimpleDateString()
        
        identify.set(
            property: "total_places",
            value: total
        )
        
        if isFirst {
            identify.set(
                property: "place_date_first",
                value: date
            )
        }
        
        identify.set(
            property: "place_date_last",
            value: date
        )
        
        amplitude?.identify(identify: identify)
        
        amplitude?.track(
            eventType: AMPEngage.placeCompleteUpload.rawValue,
            eventProperties: [
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category,
                "menu_number": model.menuArray?.count ?? 0
            ]
        )
    }
    
    func challengeClickCheckingLevelUp(isChecked: Bool) {
        amplitude?.track(
            eventType: AMPEngage.challengeClickCheckingLevelUp.rawValue,
            eventProperties: ["select": isChecked]
        )
    }
    
    func challengeView() {
        amplitude?.track(eventType: AMPEngage.challengeView.rawValue)
    }
    
    func placeClickEditPlace(model: AVIROPlaceSummary) {
        amplitude?.track(
            eventType: AMPEngage.placeClickEditPlace.rawValue,
            eventProperties: [
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func placeCompleteEditPlace(
        category: String,
        before: String,
        after: String,
        model: AVIROPlaceSummary
    ) {
        let date = Date().toString2()
        
        amplitude?.track(eventType: AMPEngage.placeCompleteEditPlace.rawValue, eventProperties: [
            "edit_category": category,
            "edit_before": before,
            "edit_detail": after,
            "edit_date": date,
            "place_name": model.title,
            "place_id": model.placeId,
            "category": model.category
        ]
        )
    }
    
    func placeClickEditMenu(model: AVIROPlaceSummary) {
        amplitude?.track(
            eventType: AMPEngage.placeClickEditMenu.rawValue,
            eventProperties: [
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func placeCompleteEditMenu(
        before: Int,
        after: Int,
        model: AVIROPlaceSummary
    ) {
        let date = Date().toString2()
        
        amplitude?.track(
            eventType: AMPEngage.placeCompleteEditMenu.rawValue,
            eventProperties: [
                "number_before": before,
                "number_detail": after,
                "edit_date": date,
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func placeClickRemove(model: AVIROPlaceSummary) {
        amplitude?.track(
            eventType: AMPEngage.placeClickRemove.rawValue,
            eventProperties: [
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    func placeCompleteRemove(model: AVIROPlaceSummary) {
        let date = Date().toString2()
        
        amplitude?.track(
            eventType: AMPEngage.placeCompleteRemove.rawValue,
            eventProperties: [
                "edit_date": date,
                "place_name": model.title,
                "place_id": model.placeId,
                "category": model.category
            ]
        )
    }
    
    // MARK: Setup User
    func signUp(with userId: String) {
        amplitude?.setUserId(userId: userId)
        amplitude?.track(eventType: AMType.signUp.rawValue)
    }
    
    // MARK: Withdrawal User
    func withdrawal() {
        amplitude?.track(
            eventType: AMType.withdrawal.rawValue
        )
    }
    
    // MARK: Login
    func login() {
        let identify = Identify()
        
        identify.set(
            property: "name",
            value: MyData.my.name
        )
        identify.set(
            property: "email",
            value: MyData.my.email
        )
        identify.set(
            property: "nickname",
            value: MyData.my.nickname
        )
        identify.set(
            property: "version",
            value: SystemUtility.appVersion ?? ""
        )
        
        amplitude?.identify(identify: identify)
        amplitude?.track(eventType: AMType.userLogin.rawValue)
    }
    
    // MARK: Logout
    func logout() {
        amplitude?.track(eventType: AMType.userLogout.rawValue)
    }
    
    // MARK: Popup Place
    func placePresent(with place: String) {
        amplitude?.track(
            eventType: AMType.placePresent.rawValue,
            eventProperties: ["Place": place]
        )
    }
    
    // MARK: Edit Menu
    func menuEdit(with place: String, beforeMenus: [AVIROMenu], afterMenus: [AVIROMenu]) {
        var beforeMenusString = ""
        
        for (index, menu) in beforeMenus.enumerated() {
            let menuString = "\(index + 1): (\(menu.menu) \(menu.price) \(menu.howToRequest))"
            beforeMenusString += menuString + "\n"
        }
        
        var afterMenusString = ""
        
        for (index, menu) in afterMenus.enumerated() {
            let menuString = "\(index + 1): (\(menu.menu) \(menu.price) \(menu.howToRequest))"
            afterMenusString += menuString + "\n"
        }
        
        amplitude?.track(
            eventType: AMType.menuEdit.rawValue,
            eventProperties: [
                "Place": place,
                "BeforeChangedMenuArray": beforeMenusString,
                "AfterChangedMenuArray": afterMenusString
            ]
        )
    }
    
    // MARK: Search Place
    func placeSearch(with query: String) {
        amplitude?.track(
            eventType: AMType.placeSearch.rawValue,
            eventProperties: ["Query": query]
        )
    }
    
    // MARK: Upload Place
    func placeUpload(with place: String) {
        amplitude?.track(
            eventType: AMType.placeUpload.rawValue,
            eventProperties: ["Place": place]
        )
    }
    
    // MARK: Upload Review
    func reviewUpload(with place: String, review: String) {
        amplitude?.track(
            eventType: AMType.reviewUpload.rawValue,
            eventProperties: [
                "Place": place,
                "Review": review
            ]
        )
    }
    
    // MARK: Request Edit Place
    func placeEdit(with place: String) {
        amplitude?.track(
            eventType: AMType.placeEdit.rawValue,
            eventProperties: ["Place": place]
        )
    }
    
    func challengePresent() {
        amplitude?.track(eventType: AMType.challPresent.rawValue)
    }
    
    func placeListPresent() {
        amplitude?.track(eventType: AMType.placeListPresent.rawValue)
    }
    
    func reviewListPresent() {
        amplitude?.track(eventType: AMType.reviewListPresent.rawValue)
    }
    
    func bookmarkListPresent() {
        amplitude?.track(eventType: AMType.bookmarkListPresent.rawValue)
    }
    
    func levelupDidMove(with level: Int) {
        amplitude?.track(
            eventType: AMType.levelupDidMove.rawValue,
            eventProperties: ["level": level]
        )
    }
    
    func levelupDidNotMove(with level: Int) {
        amplitude?.track(
            eventType: AMType.levelupDidNotMove.rawValue,
            eventProperties: ["level": level]
        )
    }
    
    func didTappedCheckWelcome() {
        amplitude?.track(eventType: AMType.wellcomeClick.rawValue)
    }
    
    func didTappedNoMoreShowWelcome() {
        amplitude?.track(eventType: AMType.wellcomeNoShow.rawValue)
    }
    
    func didTappedCloseWelcome() {
        amplitude?.track(eventType: AMType.wellcomeClose.rawValue)
    }
}

final class AmplitudeUtilityDummy: AmplitudeProtocol {
    func signUpComplete() {
        
    }
    
    func loginComplete() {
        
    }
    
    func logoutComplete() {
        
    }
    
    func withdrawalComplete() {
        
    }
    
    func searchEnterTerm(
        path: HomeSearchPath,
        number: Int,
        keyword: String
    ) {
        
    }
    
    func searchClickResult(
        index: Int,
        keyword: String,
        placeID: String?,
        placeName: String?,
        category: CategoryType?
    ) {
        
    }
    
    func bookmarkClickInPlace(clickedModel: AVIROPlaceSummary, bookmarks: Int) {
        
    }
    
    func bookmarkClickInMap() {
        
    }
    
    func bookmarkClickList() {
        
    }
    
    func placeViewSheet(path: PlaceViewSheetType, clickedModel: AVIROPlaceSummary, restaurantActive: Bool, cafeActive: Bool, barActive: Bool, bakeryActive: Bool) {
        
    }
    
    func placeViewHalf(clickedModel: AVIROPlaceSummary) {
        
    }
    
    func placeViewInfoSearched(
        type: InfoSearchType,
        scrollType: ScolledInHomeType?,
        model: AVIROPlaceSummary
    ) { }
    
    func reviewViewUpload(type: ReviewUploadPagePathType, model: AVIROPlaceSummary) {
        
    }
    
    func reviewCompleteUpload(
        model: AfterWriteReviewModel,
        placeName: String,
        category: String,
        total: Int,
        isFirst: Bool
    ) {
        
    }
    
    func placeViewUpload() {
        
    }
    
    func placeCompleteUpload(
        model: AVIROEnrollPlaceDTO,
        total: Int,
        isFirst: Bool
    ) {
        
    }
    
    func challengeClickCheckingLevelUp(isChecked: Bool) {
        
    }
    
    func challengeView() {
        
    }
    
    func placeClickEditPlace(model: AVIROPlaceSummary) {
        
    }
    
    func placeCompleteEditPlace(category: String, before: String, after: String, model: AVIROPlaceSummary) {
        
    }
    
    func placeClickEditMenu(model: AVIROPlaceSummary) {
        
    }
    
    func placeCompleteEditMenu(
        before: Int,
        after: Int,
        model: AVIROPlaceSummary
    ) {
        
    }
    
    func placeClickRemove(model: AVIROPlaceSummary) {
        
    }
    
    func placeCompleteRemove(model: AVIROPlaceSummary) {
        
    }
    
    func signUpClick(with type: LoginType) {
        return
    }
    
    func signUp(with userId: String) { return }
    func withdrawal() { return }
    func login() { return }
    func logout() { return }
    
    func placeUpload(with place: String) { return }
    func reviewUpload(
        with place: String,
        review: String
    ) { return }
    
    func placePresent(with place: String) { return }
    func placeSearch(with query: String) { return }
    
    func placeEdit(with place: String) { return }
    func menuEdit(
        with place: String,
        beforeMenus: [AVIROMenu],
        afterMenus: [AVIROMenu]
    ) { return }
    
    func challengePresent() { return }
    func placeListPresent() { return }
    func reviewListPresent() { return }
    func bookmarkListPresent() { return }
    
    func levelupDidMove(with level: Int) { return }
    func levelupDidNotMove(with level: Int) { return }
    
    func didTappedCheckWelcome() { return }
    func didTappedNoMoreShowWelcome() { return }
    func didTappedCloseWelcome() { return }
}
