

import UIKit
import AnimatedField
import Firebase

class SignUpVC: BaseClass {
    
    @IBOutlet weak var fullNameTF: AnimatedField!
    @IBOutlet weak var usernameTF: AnimatedField!
    @IBOutlet weak var emailTF: AnimatedField!
    @IBOutlet weak var passwordTF: AnimatedField!
    
    @IBOutlet weak var passwordHintLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var tickBtn: UIButton!
    @IBOutlet weak var privacyPolicyLbl: UILabel!
    
    let storage = Storage.storage()
    
    var isSocialLogin = false
    var isFromAppleLogin = false
    
    var uid = ""
    var email = ""
    var name = ""
    var profileImgUrl = ""
    var profileImg = UIImage(named: "")
    
    var isPrivacyPolicyOpened = false
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isSocialLogin {
            passwordTF.isHidden = true
            passwordHintLbl.isHidden = true
            
            if profileImgUrl != "" {
                let url = URL(string: profileImgUrl)
                let data = try? Data(contentsOf: url!)
                profileImg = UIImage(data: data!)
            }
        } else {
            passwordTF.isHidden = false
            passwordHintLbl.isHidden = false
        }
        // unHide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        self.fullNameTF.placeholder = "Full Name"
        self.fullNameTF.text = name
        self.animated_textField(tfName: fullNameTF)
        
        self.usernameTF.placeholder = "Username"
        self.animated_textField(tfName: usernameTF)
        
        self.emailTF.placeholder = "Email"
        self.emailTF.text = email
        self.animated_textField(tfName: emailTF)
        
        self.passwordTF.placeholder = "Password"
        self.animated_textField(tfName: passwordTF)
        self.passwordTF.isSecure = true
        self.passwordTF.showVisibleButton = true
        addShadowtoBtn(btn: signUpBtn)
        //signUpBtn.clipsToBounds = true
        signUpBtn.layer.cornerRadius = 8
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isPrivacyPolicyOpened {
            tickBtn.isSelected = true
            tickBtn.tintColor = .black
        }
    }
    //MARK: Button Actions
    @IBAction func tickBtn(_ sender: UIButton) {
        if sender.isSelected {
            // sender.tintColor = UIColor(red: 235.0/255.0, green: 137.0/255.0, blue: 146.0/255.0, alpha: 1)
            sender.tintColor = .black
        }
        else {
            sender.tintColor = UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 0.5)
        }
        if isPrivacyPolicyOpened == false {
            isPrivacyPolicyOpened = true
            let storyBoard = UIStoryboard(name: "InAppPurchase", bundle: nil)
            
            let vc = storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func signUpBtnAction(_ sender: Any) {
        
        createAccount()
    }
    
    //New Signup including social
    func createAccount() {
        
        resignFirstResponder()
        guard let name = fullNameTF.text, !name.isEmpty,
              let email = emailTF.text, !email.isEmpty,
              let userName = usernameTF.text, !userName.isEmpty else {
            showAlert(title: AlertConstants.Error, message: AlertConstants.AllFieldNotFilled)
            return
        }
        
        if !tickBtn.isSelected {
            showAlert(title: AlertConstants.Error, message: AlertConstants.TermsAndCondition)
            return
        }
        //TODO: Check username is having space character
        if userName.containsWhitespaceAndNewlines() == true {
            self.showAlert(title: AlertConstants.Alert, message: "White Space is not allowed")
            return
        }
        
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        
        startLoading()
        
        var param : [String:Any] = [
            "username": userName.lowercased(),
            "name": name,
            "email": email.lowercased()
        ]
        
        if isSocialLogin {
            Constants.refs.databaseUser.queryOrdered(byChild: "username").queryEqual(toValue: userName).observeSingleEvent(of: .value) { [self] snapshot in
                if snapshot.exists() {
                    self.stopLoading()
                    self.showAlert(title: "Alert", message: "User name already exists.")
                } else {
                    guard self.uid != "" else {
                        self.stopLoading()
                        self.showAlert(title: AlertConstants.Error, message: "Sign Up failed. Please try again.")
                        return
                    }
                    
                    if (self.isFromAppleLogin == true) {
                        // User is signed in
                        let user = User(id: self.uid, name: param["name"] as? String, email: param["email"] as? String, fcmToken: getFCM(), profileUrl: "", bio: "", username: param["username"] as? String, phone: "", gender: "", dob: "", address: "", parentID: self.uid, profileOn: 1, isDeleted: false, platform: "iOS", profileName: "")
                        
                        param.removeAll()
                        param = user.asDictionary
                        
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: Constants.customer)
                        UserDefaults.standard.synchronize()
                        
                        Constants.refs.databaseUser.child(uid).setValue(param) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                self.stopLoading()
                                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                                return
                            } else {
                                self.stopLoading()
                                print("Data saved successfully!")
                                
                            }
                        }
                        UserDefaults.standard.setValue(true, forKey: Constants.status)
                        self.gotoDashBoardVC()
                        
                    } else { // Login with facebook or google
                        
                        let storageRef = storage.reference().child("profilePic:\(uid).png")
                        
                        if let uploadData = profileImg?.jpegData(compressionQuality: 0.5) {
                            storageRef.putData(uploadData, metadata: nil) { [self] (metadata, error) in
                                if error != nil {
                                    self.stopLoading()
                                    self.showAlert(title: AlertConstants.Error, message: error?.localizedDescription ?? "Sign Up failed. Please try again.")
                                    print("error")
                                } else {
                                    
                                    profileImgUrl = "\(storageRef)"
                                    
                                    let user = User(id: uid, name: param["name"] as? String, email: param["email"] as? String, fcmToken: getFCM(), profileUrl: "\(storageRef)", bio: "", username: param["username"] as? String, phone: "", gender: "", dob: "", address: "", parentID: uid, profileOn: 1, isDeleted: false, platform: "iOS", profileName: "")
                                    
                                    param.removeAll()
                                    param = user.asDictionary
                                    
                                    UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: Constants.customer)
                                    UserDefaults.standard.synchronize()
                                    
                                    Constants.refs.databaseUser.child(uid).setValue(param) {
                                        (error:Error?, ref:DatabaseReference) in
                                        if let error = error {
                                            self.stopLoading()
                                            self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                                            return
                                        } else {
                                            self.stopLoading()
                                            print("Data saved successfully!")
                                            
                                        }
                                    }
                                    UserDefaults.standard.setValue(true, forKey: Constants.status)
                                    self.gotoDashBoardVC()
                                }
                            }
                        } else {
                            stopLoading()
                        }
                    }
                    
                    
                }}
        } else {
            
            guard let password = passwordTF.text, !password.isEmpty,
                  password.count > 5 else {
                showAlert(title: AlertConstants.Error, message: AlertConstants.shortPassword)
                stopLoading()
                return
            }
            
            APIManager.signUp(params: param, password: password) { (status,id,err)  in
                if status == false { // User name is already taken
                    self.stopLoading()
                    print("Error Occured",err)
                    self.showAlert(title: AlertConstants.Alert, message: err)
                } else {
                    
                    self.stopLoading()
                    
                    self.showAlert(title: AlertConstants.Success, message: AlertConstants.SignUpSuccess) {
                        
                        UserDefaults.standard.setValue(true, forKey: Constants.status)
                        self.gotoDashBoardVC()
                    }
                }
            } returnedError: { (err) in
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: err)
            }
        }
    }
    
    func gotoDashBoardVC() {
        let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                        "toBottomBarID")
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    @IBAction func privacyPolicyBtn(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "InAppPurchase", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func termsOfUseBtn(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "InAppPurchase", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
