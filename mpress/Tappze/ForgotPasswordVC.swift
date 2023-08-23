

import UIKit
import AnimatedField
import Firebase

class ForgotPasswordVC: BaseClass {
    
    @IBOutlet weak var main_bgView: UIView!
    
    @IBOutlet weak var emailTF: AnimatedField!
    @IBOutlet weak var sendBtn: UIButton!
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // unHide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        // topLeft & topRight sides round
        main_bgView.clipsToBounds = true
        main_bgView.layer.cornerRadius = 25
        main_bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.emailTF.placeholder = "Email"
        self.animated_textField(tfName: emailTF)
        self.addShadowtoBtn(btn: sendBtn)
        //sendBtn.clipsToBounds = true
        sendBtn.layer.cornerRadius = 8
        self.emailTF.text = self.email
        
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        guard let email = emailTF.text, !email.isEmpty else {
            showAlert(title: "Alert", message: AlertConstants.EmailEmpty)
            return
        }
        startLoading()
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error == nil {
                self.showAlert(title: "Alert", message: "Check your email to reset password.") {
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: error?.localizedDescription ?? AlertConstants.SomeThingWrong)
            }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
