//
//  ViewController.swift
//  SegmentConsentDemo
//
//  Created by Brandon Sneed on 9/16/19.
//  Copyright © 2019 Brandon Sneed. All rights reserved.
//

import UIKit
import Analytics

class ViewController: UIViewController {
    @IBOutlet weak var debugTextView: UITextView!
    var lastConsent = ConsentManager.shared.whatsConsented()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.debugTextView.text = lastConsent
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            let newConsent = ConsentManager.shared.whatsConsented()
            if self.lastConsent != newConsent {
                self.lastConsent = ConsentManager.shared.whatsConsented()
                self.debugTextView.text = self.lastConsent + self.debugTextView.text
            }
        }
    }
    
    func screenLog(_ msg: String) {
        debugTextView.text = "[00:00:00]" + msg + "\n" + (debugTextView.text ?? "")
    }

    @IBAction func showPrefsAction(_ sender: Any) {
        ConsentManager.shared.showConsentView()
    }
    
    @IBAction func sendIdentifyAction(_ sender: Any) {
        screenLog("Identify someUser")
        SEGAnalytics.shared()?.identify("someUser")
    }
    
    @IBAction func viewProductAction(_ sender: Any) {
        screenLog("Track \"View Product\"")
        SEGAnalytics.shared()?.track("View Product")
    }
    
    @IBAction func addProductAction(_ sender: Any) {
        screenLog("Track \"View Product\"")
        SEGAnalytics.shared()?.track("Add Product")
    }
}

