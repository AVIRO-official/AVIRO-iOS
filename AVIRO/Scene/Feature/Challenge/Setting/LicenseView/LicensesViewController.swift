//
//  LicensesViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//

import UIKit

final class LicensesViewController: UITableViewController {

    var licenses: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.shadowColor = nil
        navBarAppearance.backgroundColor = .gray7
        self.navigationItem.standardAppearance = navBarAppearance
        
        self.navigationItem.title = "오픈소스 라이선스"
        self.setupBack(true)
        
        tableView = UITableView(frame: self.view.bounds, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LicenseCell")
        
        loadLicensesFromPlist()
    }

    func loadLicensesFromPlist() {
        if let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
           let settings = NSDictionary(
            contentsOfFile: settingsBundle + "/com.mono0926.LicensePlist.plist"
           ) as? [String: Any],
           let licenseItems = settings["PreferenceSpecifiers"] as? [[String: Any]] {
            for item in licenseItems {
                if let title = item["Title"] as? String,
                   title != "Licenses" {
                    licenses.append(title)
                }
            }
            tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LicenseCell", for: indexPath)
        cell.textLabel?.text = licenses[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let licenseName = licenses[indexPath.row]
        
        if let licenseBodyText = readLicenseDetails(fromPlist: licenseName) {
            let detailViewController = LicenseDetailViewController()
            detailViewController.loadLicenseText(
                with: licenseBodyText,
                title: licenseName
            )
            navigationController?.pushViewController(detailViewController, animated: true)
        }

    }
    
    private func readLicenseDetails(fromPlist plistName: String) -> String? {
        // Settings.bundle의 URL을 구합니다.
        guard let settingsBundleURL = Bundle.main.url(forResource: "Settings", withExtension: "bundle") else {
            print("Unable to find Settings.bundle in the main bundle")
            return nil
        }
        
        // com.mono0926.LicensePlist 폴더 내의 plist 파일의 전체 경로를 구합니다.
        let licensePlistFolderPath = settingsBundleURL.appendingPathComponent("com.mono0926.LicensePlist")
        let fullPlistPath = licensePlistFolderPath.appendingPathComponent("\(plistName).plist")

        // plist 파일에서 데이터를 읽어옵니다.
        guard let plistData = try? Data(contentsOf: fullPlistPath) else {
            print("Unable to read plist data from \(fullPlistPath)")
            return nil
        }

        // PropertyListSerialization을 사용하여 plist 데이터를 딕셔너리로 변환합니다.
        do {
            if let plistContent = try PropertyListSerialization.propertyList(
                from: plistData,
                options: [],
                format: nil
            ) as? [String: Any],
               let preferenceSpecifiers = plistContent["PreferenceSpecifiers"] as? [[String: Any]] {
                for item in preferenceSpecifiers {
                    if let footerText = item["FooterText"] as? String {
                        return footerText
                    }
                }
            }
        } catch {
            print("Error serializing plist: \(error)")
        }
        
        return nil
    }
}
