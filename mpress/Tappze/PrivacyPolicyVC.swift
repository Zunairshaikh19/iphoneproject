//
//  PrivacyPolicyVC.swift
//  FirstBusiness
//
//  Created by Apple on 18/11/2022.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {

    
    @IBOutlet weak var webVu: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://avicennaenterpse.blogspot.com/2023/06/mpress-privacy-policy.html")
        let request = URLRequest(url: url!)
        webVu.load(request)
        
//        guard let webURL = URL(string:  "https://www.dropbox.com/s/zbjx1dpc5y7pa7n/PRIVACY%20POLICY%20-%20MPRESS.pdf?dl=0") else { return }
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(webURL)
//        } else {
//            UIApplication.shared.openURL(webURL)
//        }

    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
