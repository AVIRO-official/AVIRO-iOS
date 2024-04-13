//
//  System.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/10/17.
//

import UIKit

struct SystemUtility {
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/\(APP.appId.rawValue)"
    
    func latestVersion(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(APP.bundleId.rawValue)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { 
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      let appStoreVersion = results.first?["version"] as? String else {
                    completion(nil)
                    return
                }
                completion(appStoreVersion)
            }
        }
        
        task.resume()
    }
    
    func openAppStore() {
        guard let url = URL(string: SystemUtility.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
