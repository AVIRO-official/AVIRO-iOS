//
//  AVIROPostAPI.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/06/20.
//

import Foundation

struct AVIROPostAPI {
    static let scheme = "https"
    
    var host: String? = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let host = dict["AVIRO_Host"] as? String else {
            return nil
        }
        return host
    }()
    
    var apikey: String? = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let host = dict["AVIRO_Key"] as? String else {
            return nil
        }
        return host
    }()
    
    let headers = [
        "Content-Type": "application/json",
        "X-API-KEY": "\(AVIROConfiguration.apikey)"
    ]
    
    static let placeEnrollPath = "/1/map/add/place"
    static let placeListMatchedAVIROPath = "/1/map/check/place"
    static let placeListReportPath = "/1/map/report/place"
    
    static let editPlaceLocationPath = "/1/map/report/address"
    static let editPlacePhonePath = "/1/map/report/phone"
    static let editPlaceOperationPath = "/1/map/update/time"
    static let editPlaceURLPath = "/1/map/report/url"
    
    static let commentUploadPath = "/1/map/add/comment"
    static let commentEditPath = "/1/map/update/comment"
    static let commentReportPath = "/1/map/report/comment"
    static let afterUploadCommentRecommendPlace = "/1/map/add/recommend"

    static let bookmarkPostPath = "/1/map/add/bookmark"
    
    static let editMenuPath = "/1/map/update/menu"
    
    static let appleUserAutoLoginPath = "/1/member/apple"
    static let appleUserCheckPath = "/1/member"
    static let appleUserSignUpPath = "/1/member/sign-up"
    static let appleUserRevokePath = "/1/member/revoke"
    
    static let userNicnameCheckPath = "/1/member/check"
    static let userNicknameChangeablePath = "/1/member/update/nickname"
    
    // MARK: Place Enroll
    mutating func placeEnroll() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.placeEnrollPath)
    }
    
    // MARK: PlaceList Matched AVIRO
    mutating func placeListMatched() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.placeListMatchedAVIROPath)
    }
    
    // MARK: PlaceList Report
    mutating func placeReport() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.placeListReportPath)
    }
    
    // MARK: Edit Place Location
    mutating func editPlaceLocation() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editPlaceLocationPath)
    }
    
    // MARK: Edit Place Phone
    mutating func editPlacePhone() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editPlacePhonePath)
    }
    
    // MARK: Edit Place Operation
    mutating func editPlaceOperation() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editPlaceOperationPath)
    }
    
    // MARK: Edit Place URL
    mutating func editPlaceURL() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editPlaceURLPath)
    }
    
    // MARK: Comment Upload
    mutating func commentUpload() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.commentUploadPath)
    }
    
    // MARK: Comment Edit
    mutating func commentEdit() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.commentEditPath)
    }
    
    // MARK: Comment Report
    mutating func commentReport() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.commentReportPath)
    }
    
    mutating func placeRecommend() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.afterUploadCommentRecommendPlace)
    }
    
    // MARK: Bookmark Enroll/Delete
    mutating func bookmarkPost() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.bookmarkPostPath)
    }
    
    // MARK: Edit Menu Data
    mutating func editMenu() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editMenuPath)
    }
    
    // MARK: appleUserAutoLogin
    mutating func appleUserAutoLogin() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.appleUserAutoLoginPath)
    }
    
    // MARK: AppleUserCheck
    mutating func appleUserCheck() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.appleUserCheckPath)
    }
    
    // MARK: appleUserSignup
    mutating func appleUserSignup() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.appleUserSignUpPath)
    }
    
    // MARK: Withdrawal
    mutating func appleUserRevoke() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.appleUserRevokePath)
    }
    
    // MARK: Nickname Check
    mutating func nicknameCheck() -> URLComponents {
       return createURLComponents(path: AVIROPostAPI.userNicnameCheckPath)
    }
    
    // MARK: Nickname change
    mutating func nicknameChange() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.userNicknameChangeablePath)
    }
}

extension AVIROPostAPI {
    mutating func createURLComponents(path: String) -> URLComponents {
        var components = URLComponents()
        
        components.scheme = AVIROPostAPI.scheme
        components.host = host
        components.path = path
        
        return components
    }
}
