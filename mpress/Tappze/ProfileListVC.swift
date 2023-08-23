

import UIKit
import Firebase
import Appz

class ProfileListVC: BaseClass{
    
    @IBOutlet weak var profileList_tableView: UITableView!
    
    var userArr : [User]? = []
    var editedName = ""
    //var selected_id: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        profileList_tableView.delegate = self
        profileList_tableView.dataSource = self
        
        // API calling
//        self.getUserList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // API calling
        self.getUserList()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getUserList()
    {
        startLoading()
        
        // user login uid
        var user = readUserData()
        
        APIManager.getAllUsers(id: getUserId(), parentId: (user!.parentID!)) { [self] (data) in
            stopLoading()
            guard data != nil else {
                showAlert(title: AlertConstants.Error, message: "User not found.")
                return
            }
            
            // data get
            userArr = data
            self.profileList_tableView.reloadData()
            
        } error: { [self] err in
            stopLoading()
            showAlert(title: AlertConstants.Error, message: err)
        }
    }
}
// tableView extension
extension ProfileListVC: UITableViewDelegate, UITableViewDataSource
{
    // tableView code
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileListCellid") as! CellProfileList
        
        // round the Image like as Circle-Image
        cell.user_img.layer.masksToBounds = false
        cell.user_img.layer.cornerRadius = cell.user_img.frame.height/2
        cell.user_img.clipsToBounds = true
        
        // get data from firebase
        cell.fullName.text = userArr![indexPath.row].name
        cell.email.text = userArr![indexPath.row].email
        
        cell.profileNameLbl.text = userArr?[indexPath.row].profileName ?? ""
        
        if let url = userArr![indexPath.row].profileUrl, url != "" {
            print(url)
            self.downloadImage(imgVu: cell.user_img, url: url)
        }
      
        //edit btn tapped
        cell.editNameBtnPressed = {
            
            let dialogMessage = UIAlertController(title: "Alert!", message: "Enter text to change the name of profile.", preferredStyle: .alert)
            dialogMessage.addTextField { (textField) in
                textField.placeholder = "Enter First Name"
            }
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                guard let name = dialogMessage.textFields?[0].text, !name.isEmpty else {
                        self.showAlert(title: "Alert", message: "Enter text to continue")
                    return
                }
                
                let dict = ["id": self.userArr?[indexPath.row].id as Any,
                            "profileName": name]  as APIManager.dictionaryParameter
                
                APIManager.updateUserProfile(dict) { status in
                    if status == true {
                        cell.profileNameLbl.text = name
                        self.showAlert(title: "Alert", message: "Profile name saved")
                    } else {
                        self.showAlert(title: "Alert", message: "Profile name could not be saved")
                    }
                }
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button click...")
                self.dismiss(animated: true, completion: nil)
            }
            
            //Add OK and Cancel button to dialog message
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
            
           
        }
        
        
        // selected_id_img hide show
        let loggedUser = self.readUserData()
        if loggedUser?.id == userArr![indexPath.row].id {
            cell.selected_id_img.isHidden = false
        }else{
            cell.selected_id_img.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userSelected = userArr![indexPath.row]
        self.saveUserToDefaults(userSelected)
        profileList_tableView.reloadData()
        
        //        let userInfo : [String: Any] = ["selected_id": selected_id, "fromProfile": true]
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selected_id_notif"), object: nil, userInfo: userInfo)
        
        //self.dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                        "toBottomBarID")
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
