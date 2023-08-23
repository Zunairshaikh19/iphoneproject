

import UIKit
import FirebaseAuth

class visitorsCell : UITableViewCell
{
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var socialNamelbl: UILabel!
    @IBOutlet weak var totalVisitorsLbl: UILabel!
    @IBOutlet weak var socialIcon: UIImageView!
    @IBOutlet weak var novisitorFoundLabel: UILabel!
    
}

class AnalyticsVC: BaseClass {
    
    var links = [Link]()
    var userInfo: User? {didSet {
        print(userInfo as Any)
    }}
    @IBOutlet weak var savedcontaPercentageLbl: UILabel!
    
    @IBOutlet weak var linksEngPercentageLbl: UILabel!
    @IBOutlet weak var savedContctLbl: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var linkEngLbl: UILabel!
    @IBOutlet weak var visitorsTableView: UITableView!
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var savedContactView: UIView!
    @IBOutlet weak var userImageView: UIImageView!{didSet{
        userImageView.layer.cornerRadius = userImageView.bounds.height/2
        userImageView.contentMode = .scaleAspectFill
    }}
    
    @IBOutlet weak var totalCountLbl: UILabel!
    
    var analytics : Analytic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.image = UIImage(named: "user_black")

        firstView.roundViewWithDropShadow(shadowView: self.firstView, color: .lightGray, backgroundColor: .white, opacity: 0.2, offSet: .zero, radius: 10)
        secondView.roundViewWithDropShadow(shadowView: self.firstView, color: .lightGray, backgroundColor: .white, opacity: 0.2, offSet: .zero, radius: 10)
        savedContactView.roundViewWithDropShadow(shadowView: self.firstView, color: .lightGray, backgroundColor: .white, opacity: 0.2, offSet: .zero, radius: 10)
        
        visitorsTableView.delegate = self
        visitorsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        let user = readUserData()
        // user profile image download
        
        if let url = user?.profileUrl, url != "" {
            self.downloadImage(imgVu: self.userImageView, url: url)
        } else {
            userImageView.image = UIImage(named: "user_black")
        }
        if purchasedSubscription == .lifeTime {
            // API calling
            getAnalytics()
        } else {
            self.showInAppPurchaseAlert()
        }
    }
    
    func getAnalytics(){
        
        self.links.removeAll()
        
        let user = readUserData()
        self.startLoading()
        
        APIManager.getAnalytics((user?.id)!) { analytics in
            self.stopLoading()
            if analytics?.id != nil {
                self.analytics = analytics
                
                self.totalCountLbl.text = "\(analytics?.totalClicks ?? 0)"
                self.linkEngLbl.text = "\(analytics?.linksEngCrntWk ?? 0)"
                self.savedContctLbl.text = "\(analytics?.tContactsMeCrntWk ?? 0)"
                self.savedcontaPercentageLbl.text = "\(analytics?.tContactsMePastWk ?? 0)%"
                self.linksEngPercentageLbl.text = "\(analytics?.linksEngPastWk ?? 0)%"
                
                print("---links-----\(userLinks?.count ?? 0)")
                
                //TODO: Match the available social links in the profile
                for i in 0..<(userLinks?.count ?? 0) {
                    for aLink in analytics?.links ?? [] {
                        if aLink.name == userLinks?[i].name {
                            print(aLink.name!)
                            self.links.append(aLink)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.stopLoading()
                    self.visitorsTableView.reloadData()
                }
            }
        }
    }
}

extension AnalyticsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "visitorsCell", for: indexPath) as! visitorsCell
        
        if (analytics?.links!.count)! >= 1
        {
            cell.novisitorFoundLabel.isHidden = true
            cell.dataView.isHidden = false
        }
        else
        {
            cell.novisitorFoundLabel.isHidden = false
            cell.dataView.isHidden = true
        }
        
        
        cell.socialNamelbl.text = links[indexPath.row].name!
        cell.socialIcon.image = UIImage(named: (links[indexPath.row].name?.lowercased())!)
        cell.totalVisitorsLbl.text = "\(links[indexPath.row].clicks ?? 0)"
        
        var customLink: Links?
        
        for tempLink in (userLinks ?? []) {
            if links[indexPath.row].name == tempLink.name {
                if tempLink.linkID == 4, let img = UIImage(contentsOfFile: self.customLogoImgUrl.path) {
                    cell.socialIcon.image = img
                    customLink = tempLink
                }
                else if tempLink.linkID == 22, let img = UIImage(contentsOfFile: self.customLogo2ImgUrl.path) {
                    cell.socialIcon.image = img
                    customLink = tempLink
                }
                if tempLink.linkID == 23, let img = UIImage(contentsOfFile: self.customLogo3ImgUrl.path) {
                    cell.socialIcon.image = img
                    customLink = tempLink
                }
                if tempLink.linkID == 24, let img = UIImage(contentsOfFile: self.customLogo4ImgUrl.path) {
                    cell.socialIcon.image = img
                    customLink = tempLink
                }
                if tempLink.linkID == 25, let img = UIImage(contentsOfFile: self.customLogo5ImgUrl.path) {
                    cell.socialIcon.image = img
                    customLink = tempLink
                }
            }
        }
        
        if customLink != nil {
            cell.socialNamelbl.text = customLink?.name!
            cell.socialIcon.layer.cornerRadius = 5
            cell.socialIcon.contentMode = .scaleToFill
            cell.socialIcon.layer.masksToBounds = true
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (self.analytics?.links?[indexPath.row]) != nil {
            self.showAlert(title: "Links Engagements", message: "Counts of how many people open each link individually")
        }
    }
}

extension UIView{
    
    func roundViewWithDropShadowWithRadius(shadowView: UIView, color: UIColor, backgroundColor: UIColor, opacity: Float, offSet: CGSize, radius: CGFloat, shadowRadius: CGFloat, scale: Bool = true) {
        
        self.layer.shadowOffset = offSet
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
        shadowView.layer.cornerRadius = radius
    }
    
    func roundViewWithDropShadow(shadowView: UIView, color: UIColor, backgroundColor: UIColor, opacity: Float, offSet: CGSize, radius: CGFloat, scale: Bool = true) {
        
        self.layer.shadowOffset = offSet
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = 4
        UITextField.appearance().tintColor = .lightGray
        shadowView.layer.cornerRadius = radius
    }
}
