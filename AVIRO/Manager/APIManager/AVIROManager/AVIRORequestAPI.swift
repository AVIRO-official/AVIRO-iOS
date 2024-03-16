//
//  AVIRORequestAPI.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/20.
//

import Foundation

struct AVIRORequestAPI {
    static let scheme = "https"
        
    var apiVersion: String
    
    init(apiVersion: Int) {
        self.apiVersion = "/\(apiVersion)/"
    }
    
    var host: String? = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let host = dict["AVIRO_Host"] as? String else {
            return nil
        }
        return host
    }()

    
    let headers = [
        "Content-Type": "application/json",
        "X-API-KEY": "\(AVIROConfiguration.apikey)"
    ]

    // MARK: Path
    static let getNerbyStorePath = "/2/map"
    static let getBookmarkPath = "/2/map/load/bookmark"
    
    static let checkPlacePath = "/2/map/check/place"
    static let checkPlaceReportPath = "/2/map/check/place/report"
    
    static let placeSummaryPath = "/2/map/load/summary"
    static let placeInfoPath = "/2/map/load/place"
    static let menuInfoPath = "/2/map/load/menu"
    static let commentPath = "/2/map/load/comment"
    static let operationHourPath = "/2/map/load/timetable"

    static let challengeInfoPath = "/2/mypage/challenge"
    static let challengeComment = "/2/mypage/challenge/comment"
    
    static let myContributionCountPath = "/2/mypage/count"
    static let myChallengeLevelPath = "/2/mypage/challenge/level"
    
    static let myPlaceListPath = "/2/mypage/place"
    static let myCommentListPath = "/2/mypage/comment"
    static let myBookmarkListPath = "/2/mypage/bookmark"
    
    static let wellcomeImagesPath = "/2/map/load/popup"
    
    // MARK: Key
    static let userId = "userId"
    
    static let longitude = "x"
    static let latitude = "y"
    static let wide = "wide"
    static let time = "time"
    static let placeId = "placeId"
    
    static let title = "title"
    static let address = "address"
    static let x = "x"
    static let y = "y"
    
    // MARK: get Nerby Store
    mutating func getNerbyStore(with mapModel: AVIROMapModelDTO) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.longitude,
                value: mapModel.longitude
            ),
            URLQueryItem(
                name: AVIRORequestAPI.latitude,
                value: mapModel.latitude
            ),
            URLQueryItem(
                name: AVIRORequestAPI.wide,
                value: mapModel.wide
            ),
            URLQueryItem(
                name: AVIRORequestAPI.time,
                value: mapModel.time
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.getNerbyStorePath,
            queryItems: queryItems
        )
    }
    
    // MARK: get Bookmark
    mutating func getBookmark(userId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.userId,
                value: userId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.getBookmarkPath,
            queryItems: queryItems
        )
    }
    
    // MARK: Place Summary
    mutating func getPlaceSummary(placeId: String) -> URLComponents {
        
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: placeId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.placeSummaryPath,
            queryItems: queryItems
        )
    }
    
    // MARK: place Info
    mutating func getPlaceInfo(placeId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: placeId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.placeInfoPath,
            queryItems: queryItems
        )
    }
    
    // MARK: Menu Info
    mutating func getMenuInfo(placeId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: placeId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.menuInfoPath,
            queryItems: queryItems)
    }

    // MARK: Review Info
    mutating func getCommentInfo(placeId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: placeId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.commentPath,
            queryItems: queryItems
        )
    }
    
    // MARK: Operation Hour
    mutating func getOperationHours(placeId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: placeId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.operationHourPath,
            queryItems: queryItems
        )
    }
    
    // MARK: Check Place
    mutating func getCheckPlace(placeModel: AVIROCheckPlaceDTO) -> URLComponents {

        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.title,
                value: placeModel.title
            ),
            URLQueryItem(
                name: AVIRORequestAPI.address,
                value: placeModel.address
            ),
            URLQueryItem(
                name: AVIRORequestAPI.x,
                value: placeModel.x
            ),
            URLQueryItem(
                name: AVIRORequestAPI.y,
                value: placeModel.y
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.checkPlacePath,
            queryItems: queryItems
        )
    }
    
    // MARK: Check Place Report
    mutating func getCheckPlaceReport(model: AVIROPlaceReportCheckDTO) -> URLComponents {
        
        let queryItems = [
            URLQueryItem(
                name: AVIRORequestAPI.placeId,
                value: model.placeId
            ),
            URLQueryItem(
                name: AVIRORequestAPI.userId,
                value: model.userId
            )
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.checkPlaceReportPath,
            queryItems: queryItems
        )
    }
    
    // MARK: My Contribution count
    mutating func getMyContributionCount(userId: String) -> URLComponents {
        
        let queryItems = [
            URLQueryItem(name: AVIRORequestAPI.userId, value: userId)
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.myContributionCountPath,
            queryItems: queryItems
        )
    }
    
    mutating func getChallengeInfo() -> URLComponents {
        return createURLComponents(path: AVIRORequestAPI.challengeInfoPath)
    }
    
    mutating func getMyChallengeLevel(userId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(name: AVIRORequestAPI.userId, value: userId)
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.myChallengeLevelPath,
            queryItems: queryItems
        )
    }
    
    mutating func getChallengeComment() -> URLComponents {
        return createURLComponents(path: AVIRORequestAPI.challengeComment)
    }
    
    // MARK: My Place, Comment, Bookmark List
    mutating func getMyPlaceList(userId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(name: AVIRORequestAPI.userId, value: userId)
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.myPlaceListPath,
            queryItems: queryItems
        )
    }
    
    mutating func getMyCommentList(userId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(name: AVIRORequestAPI.userId, value: userId)
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.myCommentListPath,
            queryItems: queryItems
        )
    }
    
    mutating func getMyBookmarkList(userId: String) -> URLComponents {
        let queryItems = [
            URLQueryItem(name: AVIRORequestAPI.userId, value: userId)
        ]
        
        return createURLComponents(
            path: AVIRORequestAPI.myBookmarkListPath,
            queryItems: queryItems
        )
    }
    
    // MARK: GET WellcomeImages URL
    mutating func getWellcomImagesURL() -> URLComponents {
        return createURLComponents(path: AVIRORequestAPI.wellcomeImagesPath)
    }
}

extension AVIRORequestAPI {
    mutating func createURLComponents(
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) -> URLComponents {
        var components = URLComponents()
        
        components.scheme = AVIRORequestAPI.scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
}
