

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        let view = storyboard?.instantiateViewController(withIdentifier: "DashBoardVC") as? DashBoardVC
        self.setViewControllers([(view)!], animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeRootVC(_:)), name: NSNotification.Name(rawValue: "changeRootVC"), object: nil)
    }
    
    @objc func changeRootVC(_ notification: NSNotification) {
        if let name = notification.userInfo?["VCName"] as? String {
            self.setViewControllers([(storyboard?.instantiateViewController(withIdentifier: name))!], animated: false)
        }
    }
}




