//
//  ConsentManager.swift
//  SegmentConsentDemo
//
//  Created by Brandon Sneed on 9/16/19.
//  Copyright © 2019 Brandon Sneed. All rights reserved.
//

import Foundation
import OTPublishersSDK

enum ConsentGroup: String {
    case strictlyNecessary = "C0001"
    case performance = "C0002"
    case functional = "C0003"
    case targeting = "C0004"
    case socialMedia = "C0005"
    case custom = "C006"
    
    static func all() -> [ConsentGroup] {
        return [strictlyNecessary, performance, functional, targeting, socialMedia, custom]
    }
}

class ConsentManager {
    static let shared = ConsentManager()
    
    let oneTrust = OTPublishersSDK.shared
    
    init() {
    }
    
    func showConsentView() {
        //oneTrust.loadOneTrustConsentView(with: "https://cdn.cookielaw.org/consent/426524c5-55e1-4607-80f1-5831f2756d42.js", alwaysLoadBanner: true)
        oneTrust.loadOneTrustConsentView(with: "https://cdn.cookielaw.org/consent/426524c5-55e1-4607-80f1-5831f2756d42.js", alwaysLoadBanner: true) { (status, error) in
            print("done")
        }
    }
    
    func hasConsent(_ group: ConsentGroup) -> Bool {
        return oneTrust.getConsent(groupID: group.rawValue)
    }
    
    func whatsConsented() -> String {
        var result = ""
        
        for group in ConsentGroup.all() {
            result = result + "Consent for group \(group.rawValue): \(hasConsent(ConsentGroup(rawValue: group.rawValue)!))\n"
        }
        result = result + "----\n"
        
        return result
    }
}

extension OTPublishersSDK {
    func getConsent(groupID: String) -> Bool {
        // Do any additional setup after loading the view.
        guard let groupsArrayData = UserDefaults.standard.data(forKey: "OneTrustDomainGroupsArray") else {
            print("Groups Array is nil")
            return false
        }
        
        guard let groupsArray = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(groupsArrayData) as? [[String: Any]] else {
            print("Failed to convert Data to Groups Array")
            return false
        }
        
        var found: [String: Any]? = nil
        groupsArray.makeIterator().forEach { (element) in
            if element["CustomGroupId"] as? String == groupID {
                found = element
            }
        }
        
        guard let match = found else { return false }
        
        //guard let status = match["DefaultStatus"] as? String else { return false }
        
        /*if status == "always active" {
            return true
        }*/
        
        if let cookies = match["Cookies"] as? [[String: String]] {
            if let sdkId = cookies[0]["SdkId"] {
                return self.getConsentStatus(sdkId: sdkId) == 1
            }
        }
        
        return false
    }
}
