

import UIKit
import MessageUI
import Firebase

class SettingsVC: BaseClass {
    
    @IBOutlet weak var segment: UISegmentedControl!
    var usersArray : [User] = []
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        // to_Open_ProfileList_Screen
        NotificationCenter.default.addObserver(self, selector: #selector(to_Open_ProfileList_Screen_notif), name: NSNotification.Name.init("to_Open_ProfileList_Screen"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        self.getUserList()
    }
    
    //MARK: Button Actions
    
    @IBAction func affiliateBtn(_ sender: UIButton) {
        let url = URL(string: "https://profile.mypress.com/")!
        let application = UIApplication.shared
        
        if application.canOpenURL(url) {
            application.open(url)
        }
    }
    
    @IBAction func howToUseBtn(_ sender: UIButton) {
        let url = URL(string: "https://www.mpressnetwork.com/helpmpress")!
        let application = UIApplication.shared
        
        if application.canOpenURL(url) {
            application.open(url)
        }
    }
    @IBAction func referBtn(_ sender: UIButton) {
    }
    
    @IBAction func addProfileBtn(_ sender: Any) {
        if purchasedSubscription != .lifeTime {
            self.showInAppPurchaseAlert()
        } else {
            let storyboard = UIStoryboard(name: "AddProfileAlert", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "addProfileAlertVC_id") as! AddProfileAlertVC
            vc.profileAddedDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeProfileBtn(_ sender: Any) {
        if purchasedSubscription != .lifeTime {
            self.showInAppPurchaseAlert()
        } else {
            let storyboard = UIStoryboard(name: "ProfileList", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "profileList_id") as! ProfileListVC
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func changePasswordBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "forgotPassword_id") as! ForgotPasswordVC
        vc.email = self.getEmail()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func contactUsBtn(_ sender: Any) {
    
        let url = URL(string: "https://www.mpressnetwork.com/contact-us")!
        let application = UIApplication.shared
        
        if application.canOpenURL(url) {
            application.open(url)
        }
    }
    
    @IBAction func setPrivacyBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SetPrivacyVC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SetPrivacyVC") as! SetPrivacyVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func deleteAccountBtn(_ sender: Any) {
        self.showTwoBtnAlert(title: AlertConstants.Alert,
                             message: "Do you want to delete your account?",
                             yesBtn: "Yes",
                             noBtn: "No") { status in
            
            if status == true {
                print("delete")
                self.deleteUserAccount()
            }
        }
    }
    
    @IBAction func signOutBtn(_ sender: Any) {
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        
        startLoading()
        self.deleteUserModel()
        resetAppLocalStorage()
        userLinks = nil
        // for logout
        self.deleteAllCustomLinkImages()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                        "toMain")
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            stopLoading()
            
        } catch let signOutError as NSError {
            stopLoading()
            showAlert(title: AlertConstants.Error, message: signOutError.localizedDescription )
            print("Error signing out: %@", signOutError)
            return
        }
    }
    
    func resetAppLocalStorage() {
        purchasedSubscription = .none
        purchasedCard = false
        
        userLinks?.forEach({ link in
            if link.linkID == 4 || link.linkID == 22 || link.linkID == 23 || link.linkID == 24 {
                
                let linkPath = self.getLinkImgLocalPath(linkID: "LinkID\((link.linkID)!)")
                deleteLogoImageFromDocumentDirectory(url: linkPath)
            }
        })
        
        UserDefaults.standard.setValue(nil, forKey: "prof_selected_id")
        UserDefaults.standard.set(false, forKey: Constants.status)
        UserDefaults.standard.synchronize()
    }
   
    @IBAction func profileOnOff_Btn(_ sender: UISegmentedControl) {
        
        var dict = ["profileOn":0,
                    "id":getUserId()] as [String : Any]
        var a=0
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            dict["profileOn"] = 0
            APIManager.updateUserProfile(dict) { success in
                if success {
                    let storyboard = UIStoryboard(name: "ProfileStatusAlert", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "profileStatusAlert_id") as! ProfileStatusAlertVC
                    vc.tag_on_Off_status = false
                    self.present(vc, animated: true, completion: nil)
                }
            }
        case 1:
            dict["profileOn"] = 1
            APIManager.updateUserProfile(dict) { success in
                if success {
                    let storyboard = UIStoryboard(name: "ProfileStatusAlert", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "profileStatusAlert_id") as! ProfileStatusAlertVC
                    vc.tag_on_Off_status = true
                    self.present(vc, animated: true, completion: nil)
                }
            }
        default:
                  break;
        }
    }
    
    
    func segmentChanged(isProfileOn: Bool) {
     
//        if appVersion == .free {
//            self.showInAppPurchaseAlert()
//            segment.selectedSegmentIndex = 0
//            return
//        }
        
        
        
    }
    
    @objc func to_Open_ProfileList_Screen_notif(){
        let storyboard = UIStoryboard(name: "ProfileList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profileList_id") as! ProfileListVC
        self.present(vc, animated: true, completion: nil)
    }
    
    func deleteUserAccountOld() {
        // Data base will be deleted first. Because any thing in database can only be deleted when a user is logged in due to check added in firebase rules.
        self.startLoading()
        Constants.refs.databaseUser.child(getUserId()).removeValue { err, ref in
            self.stopLoading()
            
            if let err = err {
                self.showAlert(title: AlertConstants.Error, message: err.localizedDescription)
            } else {
                self.startLoading()
                let user = Auth.auth().currentUser
                user?.delete(completion: { error in
                    self.stopLoading()
                    if let error = error {
                        // An error happened.
                        self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                    } else {
                        // Account deleted.
                        self.deleteUserModel()
                        self.resetAppLocalStorage()
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                        "toMain")
                        UIApplication.shared.windows.first?.rootViewController = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                })
            }
        }
    }
}
//MARK: Profile Added Delegate
extension SettingsVC: ProfileAdded {
    func profileAdded() {
        self.getUserList()
    }
}
//MARK: Get All Users
extension SettingsVC {
    func getUserList()
    {
        startLoading()
        let user = readUserData()
        APIManager.getAllUsers(id: getUserId(), parentId: (user!.parentID!)) { [self] (data) in
            stopLoading()
            guard let data = data else {
                showAlert(title: AlertConstants.Error, message: "Users list not found.")
                return
            }
            self.usersArray = data
            
        } error: { [self] err in
            stopLoading()
            showAlert(title: AlertConstants.Error, message: err)
        }
    }
}

//MARK: Delete profile and account
extension SettingsVC {
    func deleteUserAccount() {
        let user = self.readUserData()
        if usersArray.count > 1 && user?.id == user?.parentID {
            self.showAlert(title: AlertConstants.Alert, message: "Delete other profiles first to delete basic profile")
        } else {
            self.deleteLocalProfile()
        }
    }
    
    func deleteUserFromTable() {
        // Data base will be deleted first. Because any thing in database can only be deleted when a user is logged in due to check added in firebase rules.

        self.startLoading()
        Constants.refs.databaseUser.child(getUserId()).removeValue { err, ref in
            self.stopLoading()
            
            if let err = err {
                self.showAlert(title: AlertConstants.Error, message: err.localizedDescription)
            } else {
//                if (usersArray.count) <= 1 {
//                    self.deleteUserFromAuth()
//                } else {
//                    self.deleteLocalProfile()
//                }
            }
        }
    }
    
    func deleteLocalProfile() {
        if usersArray.count > 1 {
            let updatedProfiles = usersArray.filter { $0.id != self.getUserId() }
            self.deleteUserFromTable()
            self.deleteUserModel()
            usersArray = updatedProfiles
            let user = usersArray[0]
            self.saveUserToDefaults(user)
            self.deleteAllCustomLinkImages()
            let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier:
                                                            "toBottomBarID")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            self.deleteUserFromAuth()
        }
    }
    
    func deleteUserFromAuth() {
        self.startLoading()
        let user = Auth.auth().currentUser
        user?.delete(completion: { error in
            if let error = error {
                // An error happened.
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
            } else {
                // Account deleted.
                self.deleteUserFromTable()                
                self.deleteUserModel()
                self.resetAppLocalStorage()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                "toMain")
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        })
    }
}
