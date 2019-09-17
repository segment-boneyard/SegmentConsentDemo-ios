//
//  ConsentManager.swift
//  SegmentConsentDemo
//
//  Created by Brandon Sneed on 9/16/19.
//  Copyright © 2019 Brandon Sneed. All rights reserved.
//

import Foundation
import OTPublishersSDK
import Analytics

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
    
    static func allIntegrations() -> [String] {
        var results = [String]()
        results.append(contentsOf: ConsentGroup.strictlyNecessary.integrations())
        results.append(contentsOf: ConsentGroup.performance.integrations())
        results.append(contentsOf: ConsentGroup.functional.integrations())
        results.append(contentsOf: ConsentGroup.targeting.integrations())
        results.append(contentsOf: ConsentGroup.socialMedia.integrations())
        results.append(contentsOf: ConsentGroup.custom.integrations())
        return results
    }
    
    func integrations() -> [String] {
        // TODO: these mappings ultimately need to come from segment.com
        var results = [String]()
        switch self {
        case .strictlyNecessary:
            break
        case .performance:
            results.append("Adobe Analytics")
            results.append("Nielsen DCR")
            break
        case .functional:
            results.append("Optimizely X")
            break
        case .targeting:
            results.append("comScore")
            results.append("Google Analytics")
            break
        case .socialMedia:
            break
        case .custom:
            results.append("Segment.io")
            break
        }
        return results
    }
}

public class ConsentMiddleware: NSObject, SEGMiddleware {
    struct StoredEvent {
        let context: SEGContext
        let next: SEGMiddlewareNext
    }
    
    var queue = [StoredEvent]()
    
    var lastConsent = ConsentManager.shared.whatsConsented()
    
    override init() {
        super.init()
        
        // the OT SDK doesn't call it's completion handler if alwaysLoadBanner is enabled :(
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            let newConsent = ConsentManager.shared.whatsConsented()
            if self.lastConsent != newConsent {
                self.lastConsent = ConsentManager.shared.whatsConsented()
                self.flush()
            }
        }
    }
    
    public func context(_ context: SEGContext, next: @escaping SEGMiddlewareNext) {
        if ConsentManager.shared.hasConsent(.custom) {
            let consentedIntegrations = ConsentManager.shared.consentDictionary()
            let newContext = modifyContext(context: context, integrations: consentedIntegrations)
            next(newContext)
        }
        
        // store the original to work against in the future
        // and let the server handle de-duping.
        queue.append(StoredEvent(context: context, next: next))
        if queue.count > 100 {
            queue.removeFirst()
        }
    }
    
    public func flush() {
        if ConsentManager.shared.hasConsent(.custom) {
            replay()
            if (ConsentManager.shared.allConsentObtained()) {
                queue.removeAll()
            }
            SEGAnalytics.shared()?.flush()
        }
    }
    
    func replay() {
        let consentedIntegrations = ConsentManager.shared.consentDictionary()
        for event in queue {
            event.next(modifyContext(context: event.context, integrations: consentedIntegrations))
        }
    }
    
    func modifyContext(context: SEGContext, integrations: [String: Any]) -> SEGContext {
        let newContext = context.modify { (ctx) in
            guard let payload = ctx.payload else { return }
            
            if let data = payload as? SEGTrackPayload {
                ctx.payload = SEGTrackPayload(
                    event: data.event,
                    properties: data.properties,
                    context: data.context,
                    integrations: integrations)
            } else if let data = payload as? SEGScreenPayload {
                ctx.payload = SEGScreenPayload(
                    name: data.name,
                    properties: data.properties,
                    context: data.context,
                    integrations: integrations)
            } else if let data = payload as? SEGGroupPayload {
                ctx.payload = SEGGroupPayload(
                    groupId: data.groupId,
                    traits: data.traits,
                    context: data.context,
                    integrations: integrations)
            } else if let data = payload as? SEGAliasPayload {
                ctx.payload = SEGAliasPayload(
                    newId: data.theNewId,
                    context: data.context,
                    integrations: integrations)
            } else if let data = payload as? SEGIdentifyPayload {
                ctx.payload = SEGIdentifyPayload(
                    userId: data.userId ?? "",
                    anonymousId: data.anonymousId,
                    traits: data.traits,
                    context: data.context,
                    integrations: integrations)
            } else if let data = payload as? SEGApplicationLifecyclePayload {
                let wonkyPayload = SEGApplicationLifecyclePayload(
                    context: data.context,
                    integrations: integrations)
                wonkyPayload.notificationName = data.notificationName
                wonkyPayload.launchOptions = data.launchOptions
                ctx.payload = wonkyPayload
            } else if let data = payload as? SEGContinueUserActivityPayload {
                let wonkyPayload = SEGContinueUserActivityPayload(
                    context: data.context,
                    integrations: integrations)
                wonkyPayload.activity = data.activity
                ctx.payload = wonkyPayload
            } else if let data = payload as? SEGOpenURLPayload {
                let wonkyPayload = SEGOpenURLPayload(
                    context: data.context,
                    integrations: integrations)
                wonkyPayload.url = data.url
                wonkyPayload.options = data.options
                ctx.payload = wonkyPayload
            } else if let data = payload as? SEGRemoteNotificationPayload {
                let wonkyPayload = SEGRemoteNotificationPayload(
                    context: data.context,
                    integrations: integrations)
                wonkyPayload.actionIdentifier = data.actionIdentifier
                wonkyPayload.userInfo = data.userInfo
                wonkyPayload.error = data.error
                wonkyPayload.deviceToken = data.deviceToken
                ctx.payload = wonkyPayload
            }
        }
        return newContext
    }
}

public class ConsentManager: NSObject, SEGConsentManager {    
    static let shared = ConsentManager()
    
    let oneTrust = OTPublishersSDK.shared
    
    override init() {
        super.init()
        // demo hack to get direct destinations working
        __integrationConsentManager = self
    }
    
    public func allConsentObtained() -> Bool {
        let cases = ConsentGroup.all()
        for group in cases {
            if hasConsent(group) == false {
                return false
            }
        }
        return true
    }
    
    public func consentDictionary() -> [String: Any] {
        var result = [String: Any]()
        
        let cases = ConsentGroup.all()
        for group in cases {
            let integrations = group.integrations()

            if hasConsent(group) {
                for element in integrations {
                    result[element] = true
                }
            } else {
                for element in integrations {
                    result[element] = false
                }
            }
        }
        
        result.removeValue(forKey: "Segment.io")
        return result
    }
    
    public func hasConsented(to integration: String!) -> Bool {
        var result = false
        let cases = ConsentGroup.all()
        for group in cases {
            let integrations = group.integrations()
            if hasConsent(group) && integrations.contains(integration) {
                result = true
                break
            }
        }
        return result
    }
    
    func showConsentView() {
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
            return false
        }
        
        guard let groupsArray = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(groupsArrayData) as? [[String: Any]] else {
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
