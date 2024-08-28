//
//  AVIROAPIManagerProtocol.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/09/26.
//

import Foundation

protocol AVIROAPIMangerProtocol: APIManagerProtocol {
    // MARK: - Marker / Map Refer
    /*
     - GET places
     - POST place
     - GET Check Place
     - POST Check Places
     - GET Check Place is Reported
     - GET Bookmarks
     - POST Bookmark (Overwrite)
     */
    
    // MARK: GET places
    func loadNerbyPlaceModels(
        with mapModel: AVIROMapModelDTO,
        completionHandler: @escaping (Result<AVIROMapModelResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Place
    func createPlaceModel(
        with placeModel: AVIROEnrollPlaceDTO,
        completionHandler: @escaping (Result<AVIROResultWhenChallengeDTO, APIError>) -> Void
    )
    
    // MARK: GET Check Place
    func checkPlaceOne(
        with placeModel: AVIROCheckPlaceDTO,
        completionHandler: @escaping (Result<AVIROCheckPlaceResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Check Places
    func checkPlaceList(
        with placeArray: AVIROBeforeComparePlaceDTO,
        completionHandler: @escaping (Result<AVIROAfterComparePlaceDTO, APIError>) -> Void
    )
    
    // MARK: GET Check Place is Reported
    func checkPlaceReportIsDuplicated(
        with checkReportModel: AVIROPlaceReportCheckDTO,
        completionHandler: @escaping (Result<AVIROPlaceReportCheckResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Recommend Place
    func recommendPlace(
        with infoModel: AVIRORecommendPlaceDTO,
        completionHandler: @escaping (Result<AVIRORecommendPlaceResultDTO, APIError>) -> Void
    )
    
    // MARK: GET Bookmarks
    func loadBookmarkModels(
        with userId: String,
        completionHandler: @escaping (Result<AVIROBookmarkModelResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Bookmark (Overwrite)
    func overwriteBookmarks(
        with bookmarkModel: AVIROUpdateBookmarkDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
        
    // MARK: - Detail Info Refer
    /*
     - GET Summary / loadPlaceSummary
     - GET Info / loadPlaceInfo
     - GET Menus / loadMenus
     - GET Reviews / loadReviews
     - GET Operation Hours / loadOperationHours
     - POST Review / createReview
     - POST Edit Location / editPlaceLocation
     - POST Edit Phone / editPlacePhone
     - POST Edit Operation Hours / editPlaceOperation
     - POST Edit URL / editPlaceURL
     - POST Edit Menu / editMenu
     - POST Edit Review / editReview
     - POST Report Place / reportPlace
     - POST Report Review / reportReview
     - DELETE Review / deleteReview
     */
    
    // MARK: GET Summary
    func loadPlaceSummary(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROSummaryResultDTO, APIError>) -> Void
    )
    
    // MARK: GET Info
    func loadPlaceInfo(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROPlaceInfoResultDTO, APIError>) -> Void
    )
    
    // MARK: GET Menus
    func loadMenus(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROMenusResultDTO, APIError>) -> Void
    )
    
    // MARK: GET Reviews
    func loadReviews(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROReviewsResultDTO, APIError>) -> Void
    )
    
    // MARK: GET Operation Hours
    func loadOperationHours(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROOperationHoursDTO, APIError>) -> Void
    )
    
    // MARK: POST Review
    func createReview(
        with reviewModel: AVIROEnrollReviewDTO,
        completionHandler: @escaping (Result<AVIROResultWhenChallengeDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Location
    func editPlaceLocation(
        with location: AVIROEditLocationDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Phone
    func editPlacePhone(
        with phone: AVIROEditPhoneDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Operation Hours
    func editPlaceOperation(
        with operation: AVIROEditOperationTimeDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit URL
    func editPlaceURL(
        with urlData: AVIROEditURLDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Menu
    func editMenu(
        with menu: AVIROEditMenuModel,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Review
    func editReview(
        with review: AVIROEditReviewDTO,
        completionHandler: @escaping(Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Report Place
    func reportPlace(
        with place: AVIROReportPlaceDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Report Review
    func reportReview(
        with review: AVIROReportReviewDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: DELETE Review
    func deleteReview(
        with review: AVIRODeleteReveiwDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: - My Page / Challenge
    /*
     - GET Challenge / loadChallengeInfo
     - GET User Challenge / loadUserChallengeInfo
     - GET User Contributed List Count / loadUserContributedCount
     - GET Places (user) / loadPlacesFromUser
     - GET Reviews (user) / loadREviewsFromUser
     - GET Bookmarks (user) / loadBookmarksFromUser
     */
    
    // MARK: GET Challenge
    func loadChallengeInfo(
        completionHandler: @escaping (Result<AVIROChallengeInfoDTO, APIError>) -> Void
    )
    
    // MARK: GET User Challenge
    func loadUserChallengeInfo(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyChallengeLevelResultDTO, APIError>) -> Void
    )
    
    // MARK: GET User Contributed List Count
    func loadUserContributedCount(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyContributionCountDTO, APIError>) -> Void
    )
    
    // MARK: GET Places (user)
    func loadPlacesFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyPlaceListDTO, APIError>) -> Void
    )
    
    // MARK: GET Reviews (user)
    func loadReviewsFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyCommentListDTO, APIError>) -> Void
    )
    
    // MARK: GET Bookmarks (user)
    func loadBookmarksFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyBookmarkListDTO, APIError>) -> Void
    )
    
    // MARK: - User Refer
    /*
     - POST User - Apple / createAppleUser
     - POST Check User - Apple / checkAppleUserWhenLogin
     - POST AutoLogin - Apple / checkAppleUserWhenInitiate
     - POST Revoke User - Apple / revokeAppleUser
     - POST Check Nickname Duplicated / checkNickname
     - POST Edit Nickname / editNickname
     */
    
    // MARK: POST User - Apple & Google
    func createAppleUser(
        with user: AVIROAppleUserSignUpDTO,
        completionHandler: @escaping (Result<AVIROAutoLoginWhenAppleUserResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Check User - Apple & Google
    func checkAppleUserWhenLogin(
        with appleToken: AVIROAppleUserCheckMemberDTO,
        completionHandler: @escaping (Result<AVIROAppleUserCheckMemberResultDTO, APIError>) -> Void
    )
    
    // MARK: POST User & Check User - Kakao & Naver
    func checkKakaoUserWhenLogin(
        with userId: AVIROKakaoUserCheckMemberDTO,
        completionHandler: @escaping (Result<AVIROKakaoUserCheckMemberResultDTO, APIError>) -> Void
    )
    
    // MARK: POST AutoLogin - Apple & Google
    func checkAppleUserWhenInitiate(
        with user: AVIROAutoLoginWhenAppleUserDTO,
        completionHandler: @escaping (Result<AVIROAutoLoginWhenAppleUserResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Revoke User - Apple
    func revokeAppleUser(
        with user: AVIRORevokeUserDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Check Nickname Duplicated
    func checkNickname(
        with nickname: AVIRONicknameIsDuplicatedCheckDTO,
        completionHandler: @escaping (Result<AVIRONicknameIsDuplicatedCheckResultDTO, APIError>) -> Void
    )
    
    // MARK: POST Edit Nickname
    func editNickname(
        with nickname: AVIRONicknameChagneableDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    )
    
    // MARK: Popup
    func loadWelcomePopups(
        completionHandler: @escaping (Result<AVIROWelcomeDTO, APIError>) -> Void
    )
}
