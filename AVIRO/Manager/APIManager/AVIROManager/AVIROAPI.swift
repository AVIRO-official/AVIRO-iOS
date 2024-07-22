//
//  AVIROAPIModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/20.
//

import Foundation

final class AVIROAPI: AVIROAPIMangerProtocol {
    static let manager = AVIROAPI()
    var onRequest: Set<URL> = []
    
    var session: URLSession
    
    var postAPI = AVIROPostAPI()
    var requestAPI = AVIRORequestAPI(apiVersion: 2)
    var deleteAPI = AVIRODeleteAPI()
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
        
    internal func performRequest<T>(
        with url: URL,
        httpMethod: HTTPMethodType = .get,
        requestBody: Data? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping (Result<T, APIError>) -> Void
    ) where T: Decodable {
        guard !onRequest.contains(url) else { return }
        
        onRequest.insert(url)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        request.httpBody = requestBody
        
        print("----------")
        print(request)
        print("----------")
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.onRequest.remove(url)
            }

            if let error = error {
                completionHandler(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            if let apiError = self?.handleStatusCode(with: httpResponse.statusCode) {
                completionHandler(.failure(apiError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.badRequest))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(decodedObject))
            } catch {
                completionHandler(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    private func handleStatusCode(with code: Int) -> APIError? {
        switch code {
        case 100..<200:
            return APIError.informationResponse
        case 200..<300:
            return nil
        case 300..<400:
            return APIError.redirectionRequired
        case 400..<500:
            return APIError.clientError(code)
        case 500...:
            return APIError.serverError(code)
        default:
            return APIError.badRequest
        }
    }

    // MARK: - Marker Refer
    /*
     - GET places / loadNerbyPlaceModels
     - POST place / createPlaceModel
     - GET Check Place / checkPlaceOne
     - POST Check Places / checkPlaceList
     - GET Check Place is Reported / checkPlaceReportIsDuplicated
     - POST Recommend Place / recommendPlace
     - GET Bookmarks  / loadBookmarkModels
     - POST Bookmark (Overwrite) / overwriteBookmarks
     */
    
    // MARK: GET places
    func loadNerbyPlaceModels(
        with mapModel: AVIROMapModelDTO,
        completionHandler: @escaping (Result<AVIROMapModelResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getNerbyStore(with: mapModel).url else {
            completionHandler(.failure(.urlError))
            return
        }
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Place
    func createPlaceModel(
        with placeModel: AVIROEnrollPlaceDTO,
        completionHandler: @escaping (Result<AVIROResultWhenChallengeDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.placeEnroll().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(placeModel) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Check Place
    func checkPlaceOne(
        with placeModel: AVIROCheckPlaceDTO,
        completionHandler: @escaping (Result<AVIROCheckPlaceResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getCheckPlace(placeModel: placeModel).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Check Places
    func checkPlaceList(
        with placeArray: AVIROBeforeComparePlaceDTO,
        completionHandler: @escaping (Result<AVIROAfterComparePlaceDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.placeListMatched().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(placeArray) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Check Place is Reported
    func checkPlaceReportIsDuplicated(
        with checkReportModel: AVIROPlaceReportCheckDTO,
        completionHandler: @escaping (Result<AVIROPlaceReportCheckResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getCheckPlaceReport(model: checkReportModel).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Recommend Place
    func recommendPlace(
        with infoModel: AVIRORecommendPlaceDTO,
        completionHandler: @escaping (Result<AVIRORecommendPlaceResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.placeRecommend().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(infoModel) else {
            completionHandler(.failure(.encodingError))
            return
        }
        
        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Bookmarks (Overwrite)
    func loadBookmarkModels(
        with userId: String,
        completionHandler: @escaping (Result<AVIROBookmarkModelResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getBookmark(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Bookmark
    func overwriteBookmarks(
        with bookmarkModel: AVIROUpdateBookmarkDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.bookmarkPost().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(bookmarkModel) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }

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
    ) {
        guard let url = requestAPI.getPlaceSummary(placeId: placeId).url else {
            completionHandler(.failure(.urlError))
            return
        }
                
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Info
    func loadPlaceInfo(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROPlaceInfoResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getPlaceInfo(placeId: placeId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Menus
    func loadMenus(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROMenusResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMenuInfo(placeId: placeId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Reviews
    func loadReviews(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROReviewsResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getCommentInfo(placeId: placeId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Operation Hours
    func loadOperationHours(
        with placeId: String,
        completionHandler: @escaping (Result<AVIROOperationHoursDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getOperationHours(placeId: placeId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    
    // MARK: POST Review
    func createReview(
        with reviewModel: AVIROEnrollReviewDTO,
        completionHandler: @escaping (Result<AVIROResultWhenChallengeDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.commentUpload().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(reviewModel) else {
            completionHandler(.failure(.encodingError))
            return
        }
        
        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Location
    func editPlaceLocation(
        with location: AVIROEditLocationDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.editPlaceLocation().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(location) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Phone
    func editPlacePhone(
        with phone: AVIROEditPhoneDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.editPlacePhone().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(phone) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Operation Hours
    func editPlaceOperation(
        with operation: AVIROEditOperationTimeDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.editPlaceOperation().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(operation) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit URL
    func editPlaceURL(
        with urlData: AVIROEditURLDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.editPlaceURL().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(urlData) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Menu
    func editMenu(
        with menu: AVIROEditMenuModel,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>
        ) -> Void) {
        guard let url = postAPI.editMenu().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(menu) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Review
    func editReview(
        with review: AVIROEditReviewDTO,
        completionHandler: @escaping(Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.commentEdit().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(review) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Report Place
    func reportPlace(
        with place: AVIROReportPlaceDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.placeReport().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(place) else {
            completionHandler(.failure(.encodingError))
            return
        }
        
        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Report Review
    func reportReview(
        with review: AVIROReportReviewDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.commentReport().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(review) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: DELETE Review
    func deleteReview(
        with review: AVIRODeleteReveiwDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = deleteAPI.deleteComment(model: review).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            httpMethod: .delete,
            headers: deleteAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: - My Page / Challenge
    /*
     - GET Challenge / loadChallengeInfo
     - GET Challenge Comment / loadChallengeComment
     - GET User Challenge / loadUserChallengeInfo
     - GET User Contributed List Count / loadUserContributedCount
     - GET Places (user) / loadPlacesFromUser
     - GET Reviews (user) / loadREviewsFromUser
     - GET Bookmarks (user) / loadBookmarksFromUser
     */
    
    // MARK: GET Challenge
    func loadChallengeInfo(
        completionHandler: @escaping (Result<AVIROChallengeInfoDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getChallengeInfo().url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Challenge Comment
    func loadChallengeComment(completionHandler: @escaping (Result<AVIROChallengeCommentDTO, APIError>) -> Void) {
        guard let url = requestAPI.getChallengeComment().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET User Challenge
    func loadUserChallengeInfo(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyChallengeLevelResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMyChallengeLevel(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET User Contributed List Count
    func loadUserContributedCount(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyContributionCountDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMyContributionCount(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Places (user)
    func loadPlacesFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyPlaceListDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMyPlaceList(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Reviews (user)
    func loadReviewsFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyCommentListDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMyCommentList(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET Bookmarks (user)
    func loadBookmarksFromUser(
        with userId: String,
        completionHandler: @escaping (Result<AVIROMyBookmarkListDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getMyBookmarkList(userId: userId).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: - User Refer
    /*
     - POST User - Apple / createAppleUser
     - POST Check User - Apple / checkAppleUserWhenLogin
     - POST AutoLogin - Apple / checkAppleUserWhenInitiate
     - POST Revoke User - Apple / revokeAppleUser
     - POST Check Nickname Duplicated / checkNickname
     - POST Edit Nickname / editNickname
     */
    
    // MARK: POST User - Apple
    func createAppleUser(
        with user: AVIROAppleUserSignUpDTO,
        completionHandler: @escaping (Result<AVIROAutoLoginWhenAppleUserResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.appleUserSignup().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(user) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Check User - Apple
    func checkAppleUserWhenLogin(
        with appleToken: AVIROAppleUserCheckMemberDTO,
        completionHandler: @escaping (Result<AVIROAppleUserCheckMemberResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.appleUserCheck().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(appleToken) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: GET AutoLogin / Check User - Kakao & Naver
    func checkKakaoUserWhenLogin(
        with userId: AVIROKakaoUserCheckMemberDTO,
        completionHandler: @escaping (Result<AVIROKakaoUserCheckMemberResultDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.kakaoUserCheck(userId: userId.userId).url else {
            completionHandler(.failure(.urlError))
            return
        }

        guard let jsonData = try? JSONEncoder().encode(userId) else {
            completionHandler(.failure(.encodingError))
            return
        }
                
        performRequest(
            with: url,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST AutoLogin - Apple
    func checkAppleUserWhenInitiate(
        with user: AVIROAutoLoginWhenAppleUserDTO,
        completionHandler: @escaping (Result<AVIROAutoLoginWhenAppleUserResultDTO, APIError>) -> Void
    ) {
        
        guard let url = postAPI.appleUserAutoLogin().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(user) else {
            completionHandler(.failure(.encodingError))
            return
        }
        
        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Revoke User - Apple
    func revokeAppleUser(
        with user: AVIROAutoLoginWhenAppleUserDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.appleUserRevoke().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(user) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Check Nickname Duplicated
    func checkNickname(
        with nickname: AVIRONicknameIsDuplicatedCheckDTO,
        completionHandler: @escaping (Result<AVIRONicknameIsDuplicatedCheckResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.nicknameCheck().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(nickname) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // MARK: POST Edit Nickname
    func editNickname(
        with nickname: AVIRONicknameChagneableDTO,
        completionHandler: @escaping (Result<AVIROResultDTO, APIError>) -> Void
    ) {
        guard let url = postAPI.nicknameChange().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(nickname) else {
            completionHandler(.failure(.encodingError))
            return
        }

        performRequest(
            with: url,
            httpMethod: .post,
            requestBody: jsonData,
            headers: postAPI.headers,
            completionHandler: completionHandler
        )
    }
    
    // - MARK: ETC
    /*
     - GET Wellcome Images URL / loadWellcomeImagesURL
     */
    
    // MARK: Get wellcomeImagesURL
    func loadWellcomeImagesURL(
        completionHandler: @escaping (Result<AVIROWellcomeDTO, APIError>) -> Void
    ) {
        guard let url = requestAPI.getWellcomImagesURL().url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: requestAPI.headers,
            completionHandler: completionHandler
        )
    }
}
