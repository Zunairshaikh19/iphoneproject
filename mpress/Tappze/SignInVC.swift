

import UIKit
import AnimatedField
import FirebaseAuth

class SignInVC: BaseClass {
    
    @IBOutlet weak var emailTF: AnimatedField!
    @IBOutlet weak var passwordTF: AnimatedField!
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        addShadowtoBtn(btn: signInBtn)
        navigationController?.navigationBar.isHidden = false
        
        emailTF.placeholder = "Email"
        animated_textField(tfName: emailTF)
        
        passwordTF.placeholder = "Password"
        animated_textField(tfName: passwordTF)
        passwordTF.isSecure = true
        passwordTF.showVisibleButton = true
        
        signInBtn.clipsToBounds = false
        signInBtn.layer.cornerRadius = 8
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        view.endEditing(true) // Dismiss the keyboard
        
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            showAlert(title: AlertConstants.Error, message: AlertConstants.AllFieldNotFilled)
            return
        }
        
        startLoading()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            self.stopLoading()
            
            if let error = error {
                let errorMsg = error.localizedDescription
                self.showAlert(title: AlertConstants.Error, message: errorMsg)
                return
            }
            
            if let user = authResult?.user {
                print(user.email ?? "No email")
                
                APIManager.getUserData(id: user.uid) { [weak self] (user) in
                    guard let self = self else { return }
                    
                    guard let user = user else {
                        self.showAlert(title: AlertConstants.Error, message: "Could not find user data.")
                        return
                    }
                    
                    if let isDeleted = user.isDeleted, isDeleted {
                        self.showAlert(title: AlertConstants.Alert, message: "Your Account is locked, contact admin.")
                    } else {
                        self.saveUserToDefaults(user)
                        self.stopLoading()
                                               
                                               print("Saved Data to user defaults", user as Any)
                                                                       
                                               //TODO: check subscription type
                                               if let subscrition = user.subscription {
                                                   switch subscrition {
                                                   case "monthly":
                                                       purchasedSubscription = .monthly
                                                   case "yearly":
                                                       purchasedSubscription = .yearly
                                                   case "lifeTime":
                                                       purchasedSubscription = .lifeTime
                                                   case "none":
                                                       purchasedSubscription = .none
                                                   default:
                                                       purchasedSubscription = .none
                                                   }
                                               }
                                               
                                               let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
                                               let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                                               "toBottomBarID")
                                               UIApplication.shared.windows.first?.rootViewController = vc
                                               UIApplication.shared.windows.first?.makeKeyAndVisible()
                        
                    }
                } error: { [weak self] (desc) in
                    self?.showAlert(title: AlertConstants.Error, message: desc)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "forgotPassword_id") as? ForgotPasswordVC {
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
