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
        //t
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

protocol AmplitudeProtocol {
    func signUpClick(with type: LoginType)
    func signUpComplete()
    func loginComplete()
    func logoutComplete()
    func withdrawalComplete()
    
    func searchEnterTerm()
    func searchClickResult()
    func bookmarkClickInPlace()
    func bookmarkClickInMap()
    func bookmarkClickList()
    func placeViewSheet()
    func placeViewHalf()
    func placeViewMenu()
    func placeViewReview()
    
    func reviewViewUpload()
    func reviewCompleteUpload()
    func placeViewUpload()
    func placeCompleteUpload()
    func challengeClickCheckingLevelUp()
    func challengeView()
    func placeClickEditPlace()
    func placeCompleteEditPlace()
    func placeClickEditMenu()
    func placeCompleteEditMenu()
    func placeClickRemove()
    func placeCompleteRemove()
    
    func signUp(with userId: String)
    func withdrawal()
    func login()
    func logout()
    
    func placeUpload(with place: String)
    func reviewUpload(with place: String, review: String)
    
    func placePresent(with place: String)
    func placeSearch(with query: String)

    func placeEdit(with place: String)
    func menuEdit(with place: String, beforeMenus: [AVIROMenu], afterMenus: [AVIROMenu])
    
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
        identify.set(property: "auth_type", value: type.rawValue)
        
        amplitude?.identify(identify: identify)
        amplitude?.track(
            eventType: AMPUserType.signUpClick.rawValue
        )
    }
    
    func signUpComplete() {
        
    }
    
    func loginComplete() {
        
    }
    
    func logoutComplete() {
        
    }
    
    func withdrawalComplete() {
        
    }
    
    func searchEnterTerm() {
        
    }
    
    func searchClickResult() {
        
    }
    
    func bookmarkClickInPlace() {
        
    }
    
    func bookmarkClickInMap() {
        
    }
    
    func bookmarkClickList() {
        
    }
    
    func placeViewSheet() {
        
    }
    
    func placeViewHalf() {
        
    }
    
    func placeViewMenu() {
        
    }
    
    func placeViewReview() {
        
    }
    
    func reviewViewUpload() {
        
    }
    
    func reviewCompleteUpload() {
        
    }
    
    func placeViewUpload() {
        
    }
    
    func placeCompleteUpload() {
        
    }
    
    func challengeClickCheckingLevelUp() {
        
    }
    
    func challengeView() {
        
    }
    
    func placeClickEditPlace() {
        
    }
    
    func placeCompleteEditPlace() {
        
    }
    
    func placeClickEditMenu() {
        
    }
    
    func placeCompleteEditMenu() {
        
    }
    
    func placeClickRemove() {
        
    }
    
    func placeCompleteRemove() {
        
    }
    
    // MARK: Setup User
    func signUp(with userId: String) {
        amplitude?.setUserId(userId: userId)
        amplitude?.track(eventType: AMType.signUp.rawValue)
    }
    
    // MARK: Withdrawal User
    func withdrawal() {
        amplitude?.track(eventType: AMType.withdrawal.rawValue)
    }
    
    // MARK: Login
    func login() {
        let identify = Identify()
        identify.set(property: "name", value: MyData.my.name)
        identify.set(property: "email", value: MyData.my.email)
        identify.set(property: "nickname", value: MyData.my.nickname)
        identify.set(property: "version", value: SystemUtility.appVersion ?? "")
        
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
    
    func searchEnterTerm() {
        
    }
    
    func searchClickResult() {
        
    }
    
    func bookmarkClickInPlace() {
        
    }
    
    func bookmarkClickInMap() {
        
    }
    
    func bookmarkClickList() {
        
    }
    
    func placeViewSheet() {
        
    }
    
    func placeViewHalf() {
        
    }
    
    func placeViewMenu() {
        
    }
    
    func placeViewReview() {
        
    }
    
    func reviewViewUpload() {
        
    }
    
    func reviewCompleteUpload() {
        
    }
    
    func placeViewUpload() {
        
    }
    
    func placeCompleteUpload() {
        
    }
    
    func challengeClickCheckingLevelUp() {
        
    }
    
    func challengeView() {
        
    }
    
    func placeClickEditPlace() {
        
    }
    
    func placeCompleteEditPlace() {
        
    }
    
    func placeClickEditMenu() {
        
    }
    
    func placeCompleteEditMenu() {
        
    }
    
    func placeClickRemove() {
        
    }
    
    func placeCompleteRemove() {
        
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
