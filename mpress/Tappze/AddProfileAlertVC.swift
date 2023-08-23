

import UIKit
import Firebase
import FirebaseAuth

protocol ProfileAdded {
    func profileAdded()
}
class AddProfileAlertVC: BaseClass {
    
    @IBOutlet weak var main_bgView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var profileAddedDelegate: ProfileAdded?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        main_bgView.clipsToBounds = true
        main_bgView.layer.cornerRadius = 22
        
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 8
        
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 8
        
    }
   
    
    @IBAction func okBtnAction(_ sender: Any) {
        
        self.dismiss(animated: false, completion: {
            
            // NotificationObserver
            NotificationCenter.default.post(name: NSNotification.Name.init("to_Open_ProfileList_Screen"), object: nil)
        
            let key = Constants.refs.databaseUser.childByAutoId().key
            let usr = self.readUserData()
            /*
             Create new object based on parent object data
             */
            let rand = self.randomString(length: 6)
            let usNm = (usr?.username)! + rand
            let data = ["address": "",
                        "bio": "",
                        "dob": "",
                        "email": (usr?.email)!,
                        "fcmToken": "",
                        "gender": "",
                        "id": key!,
                        "isDeleted": false,
                        "name": (usr?.name)!,
                        "parentID": (usr?.parentID)!,
                        "phone": "",
                        "platform": "iOS",
                        "profileOn": (usr?.profileOn)!,
                        "subscription": usr?.subscription ?? "",
                        "subscriptionPurchaseDate": usr?.subscriptionPurchaseDate ?? "",
                        "subscriptionExpiryDate": usr?.subscriptionExpiryDate ?? "",
                        "isProVersion":true,
                        "isSubscribed": true,
                        "username": usNm] as [String : Any]
            //TODO: Add to firebase
            Constants.refs.databaseUser.child(key!).setValue(data) { (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Profile can not be added: \(error).")
                } else {
                    self.profileAddedDelegate?.profileAdded()
                    print("Profile added successfully!")
                }
            }
            
        })
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: false)
    
   }
}
