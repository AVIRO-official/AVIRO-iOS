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
              let host = dict["AVIROHost"] as? String else {
            print("Failed to load AVIROHost from API.plist")
            return nil
        }
        return host
    }()
    
    let headers = ["Content-Type": "application/json"]

    static let placeEnrollPath = "/prod/map/add/place"
    static let placeListMatchedAVIROPath = "/prod/map/check/place"
    static let placeListReportPath = "/prod/map/report/place"
    
    static let editPlaceLocationPath = "/prod/map/report/address"
    static let editPlacePhonePath = "/prod/map/report/phone"
    static let editPlaceOperationPath = "/prod/map/update/time"
    static let editPlaceURLPath = "/prod/map/report/url"
    
    static let commentUploadPath = "/prod/map/add/comment"
    static let commentEditPath = "/prod/map/update/comment"
    static let commentReportPath = "/prod/map/report/comment"

    static let bookmarkPostPath = "/prod/map/add/bookmark"
    
    static let editMenuPath = "/prod/map/update/menu"
    
    static let userIdCheckPath = "/prod/member"
    static let appleUserCheckPath = "/prod/member/apple"

    static let userSignUpPath = "/prod/member/sign-up"
    static let userNicnameCheckPath = "/prod/member/check"
    static let userNicknameChangeablePath = "/prod/member/update/nickname"
    static let userWithdrawPath = "/prod/member/withdraw"
    
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
    
    // MARK: Bookmark Enroll/Delete
    mutating func bookmarkPost() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.bookmarkPostPath)
    }
    
    // MARK: Edit Menu Data
    mutating func editMenu() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.editMenuPath)
    }
    
    // MARK: UserId Check
    mutating func userIdCheck() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.userIdCheckPath)
    }
    
    // MARK: AppleUserCheck
    mutating func appleUserCheck() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.appleUserCheckPath)
    }
    
    // MARK: user Sign up 
    mutating func userSignup() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.userSignUpPath)
    }
    
    // MARK: Nickname Check
    mutating func nicknameCheck() -> URLComponents {
       return createURLComponents(path: AVIROPostAPI.userNicnameCheckPath)
    }
    
    // MARK: Nickname change
    mutating func nicknameChange() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.userNicknameChangeablePath)
    }
    
    // MARK: Withdrawal
    mutating func userWithdraw() -> URLComponents {
        return createURLComponents(path: AVIROPostAPI.userWithdrawPath)
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
