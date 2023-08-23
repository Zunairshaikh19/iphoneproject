

import UIKit
import Appz
import FirebaseStorage
import CropViewController

class InsertLinkVC: BaseClass {
    
    @IBOutlet weak var outerView: UIView! {
        didSet {
//            addShadow(view: outerView)
//            outerView.layer.cornerRadius = outerView.layer.frame.height/2
            
        }
    }
    @IBOutlet weak var mainVu: UIView!
    @IBOutlet weak var topLbl: UILabel! {
        didSet {
            addShadow(view: topLbl)
        }
    }
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var imgVu: UIImageView!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var editLinkNameField: UITextField!
    @IBOutlet weak var editLinkNameBtn: UIButton!
    @IBOutlet weak var editLinkLogoImgVu: UIImageView!
    
    @IBOutlet weak var isSharedSwitch: UISwitch!
    var selectedLink:Links?
    var isViewOnly = false
    var platform = ""
    var text = ""
    var delegate: LinkAdded?
    var deleteDelegate : LinkDeleted?
    let storage = Storage.storage()
    var img = ""
    
    var customLinkImageUrl = ""
    var customLogoImageName = ""
    var imagePicked = false
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadow(view: userNameField)
        addShadow(view: openBtn)
        addShadow(view: deleteBtn)
        addShadow(view: saveBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (selectedLink?.linkID == 4 || selectedLink?.linkID == 22 || selectedLink?.linkID == 23 || selectedLink?.linkID == 24 || selectedLink?.linkID == 25) && selectedLink?.value != "" {
            customLogoImageName = selectedLink?.image ?? ""
        }
        self.initialViewSetup()
    }
    
    override func viewWillLayoutSubviews() {
        mainVu.roundCorners(corners: [.topLeft,.topRight], radius: 30.0)
    }
    
    //MARK: Initial View Setup
    private func initialViewSetup() {
        
        userNameField.text = text
        isSharedSwitch.isOn = selectedLink?.isShared ?? false
        if selectedLink?.linkID == 4 || selectedLink?.linkID == 22 || selectedLink?.linkID == 23 || selectedLink?.linkID == 24 || selectedLink?.linkID == 25{
            editLinkNameBtn.isHidden = false
            editLinkNameField.isHidden = false
            topLbl.isHidden = true
            editLinkNameField.text = platform.capitalized
            userNameField.placeholder = "https://www.example.com/"
        }
        else {
            topLbl.isHidden = false
            topLbl.text = platform.capitalized
        }
        
        self.imageViewSetup()

        switch platform.lowercased() {
        case "whatsapp":
            userNameField.placeholder = "Phone Number"
        case "linkedin":
            userNameField.placeholder = "LinkedIn Profile Link"
        case "twitter","telegram","instagram":
            userNameField.placeholder = "Username"
        case "youtube":
            userNameField.placeholder = "Youtube profile link"
        case "facebook":
            userNameField.placeholder = "Facebook profile link"
            break
        case "pinterest":
            userNameField.placeholder = "Pintrest profile link"
            break
        case "vimeo":
            userNameField.placeholder = "Link"
        case "snapchat","tiktok":
            userNameField.placeholder = "Username"
        case "email":
            userNameField.placeholder = "Email"
        case "spotify":
            userNameField.placeholder = "Album or Artist"
        case "paypal":
            userNameField.placeholder = "PayPal.me link"
//        case "custom link":
//            userNameField.placeholder = "https://www.example.com/"
        case "website", "custom link 1", "custom link 2","custom link 3","custom link 4","custom link 5" :
            userNameField.placeholder = "https://www.example.com/"
//        case "contact card","text":
//            userNameField.placeholder = "Phone Number"
//        case "paylah":
//            userNameField.placeholder = "Paylah Profile Url"
        case "calendly":
            userNameField.placeholder = "Calendly Url"
        case "google":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "yelp":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "portfolio":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "shop":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "menu":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "catalog":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "open table":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "venmo":
            userNameField.placeholder = "https://www.example.com/"
            break
        case "wi-fi":
            userNameField.placeholder = "https://www.example.com/"
            break
            
        default:
            userNameField.placeholder = platform
        }
        
        if isViewOnly {
            userNameField.isUserInteractionEnabled = false
            deleteBtn.isHidden = true
            saveBtn.setTitle("Close", for: .normal)
        }
    }
    
    
    //MARK: Custom logoImage view Setup
    private func imageViewSetup() {
        
        self.imgVu.image = UIImage(named: platform.lowercased())

        // For Custom link. Check if link already added and image exist.
        if  let selectedLink = selectedLink, (selectedLink.linkID == 4 || selectedLink.linkID == 22 || selectedLink.linkID == 23 || selectedLink.linkID == 24 || selectedLink.linkID == 25)  {
            
            editLinkLogoImgVu.isHidden = false
            let addLogoGesture = UITapGestureRecognizer(target: self, action: #selector(self.imgVuTapped))
            imgVu.isUserInteractionEnabled = true
            addLogoGesture.numberOfTapsRequired = 1
            addLogoGesture.delaysTouchesBegan = true
            imgVu.addGestureRecognizer(addLogoGesture)
            
            imgVu.layer.cornerRadius = 10
        }
        if selectedLink?.linkID == 4 {
            customLinkImageUrl = selectedLink?.image ?? ""
            if (selectedLink?.value != "" && selectedLink?.value != nil && customLinkImageUrl != ""), let img = UIImage(contentsOfFile: self.customLogoImgUrl.path) {
                self.imgVu.contentMode = .scaleToFill
                self.imgVu.borderWidthV = 1
                self.imgVu.borderColorV = UIColor.black
                self.imgVu.image = img
            }
            else {
                self.imgVu.image = UIImage(named: "custom link 1")
            }
        }
        else if selectedLink?.linkID == 22 {
            customLinkImageUrl = selectedLink?.image ?? ""
            if (selectedLink?.value != "" && selectedLink?.value != nil  && customLinkImageUrl != ""), let img = UIImage(contentsOfFile: self.customLogo2ImgUrl.path) {
                self.imgVu.contentMode = .scaleToFill
                self.imgVu.borderWidthV = 1
                self.imgVu.borderColorV = UIColor.black
                self.imgVu.image = img
            }
            else {
                self.imgVu.image = UIImage(named: "custom link 1")

                //self.imgVu.loadGif(name: "CustomLink2")
            }
        }
        else if selectedLink?.linkID == 23 {
            customLinkImageUrl = selectedLink?.image ?? ""
            if (selectedLink?.value != "" && selectedLink?.value != nil && customLinkImageUrl != ""), let img = UIImage(contentsOfFile: self.customLogo3ImgUrl.path) {
                self.imgVu.contentMode = .scaleToFill
                self.imgVu.borderWidthV = 1
                self.imgVu.borderColorV = UIColor.black
                self.imgVu.image = img
            }
            else {
                self.imgVu.image = UIImage(named: "custom link 1")

            }
        }
        else if selectedLink?.linkID == 24 {
            customLinkImageUrl = selectedLink?.image ?? ""
            if (selectedLink?.value != "" && selectedLink?.value != nil && customLinkImageUrl != ""), let img = UIImage(contentsOfFile: self.customLogo4ImgUrl.path) {
                self.imgVu.contentMode = .scaleToFill
                self.imgVu.borderWidthV = 1
                self.imgVu.borderColorV = UIColor.black
                self.imgVu.image = img
            }
            else {
                self.imgVu.image = UIImage(named: "custom link 1")
            }
        } else if selectedLink?.linkID == 25 {
            customLinkImageUrl = selectedLink?.image ?? ""
            if (selectedLink?.value != "" && selectedLink?.value != nil && customLinkImageUrl != ""), let img = UIImage(contentsOfFile: self.customLogo5ImgUrl.path) {
                self.imgVu.contentMode = .scaleToFill
                self.imgVu.borderWidthV = 1
                self.imgVu.borderColorV = UIColor.black
                self.imgVu.image = img
            }
            else {
                self.imgVu.image = UIImage(named: "custom link 1")
            }
        }
        else {
            self.imgVu.image = UIImage(named: platform.lowercased())
        }
    }
    
    @objc func imgVuTapped (sender: UITapGestureRecognizer){
        
        resignFirstResponder()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
        
    override func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.imgVu.image = image
        self.imagePicked = true

        switch selectedLink?.linkID! {
        case 4:
            customLogoImageName = "customLogoImg:\(getUserId()).png"
        case 22:
            customLogoImageName = "customLogoImg2:\(getUserId()).png"
        case 23:
            customLogoImageName = "customLogoImg3:\(getUserId()).png"
        case 24:
            customLogoImageName = "customLogoImg4:\(getUserId()).png"
        case 25:
            customLogoImageName = "customLogoImg5:\(getUserId()).png"
        default:
            customLogoImageName = "customLogoImg:\(getUserId()).png"
        }
        var storageRef = storage.reference()
        storageRef = storage.reference().child(customLogoImageName)
        customLogoImageName = "\(storageRef)"
        //TODO: Compress image
        if let uploadData = image.jpegData(compressionQuality: 0.25) {
            storageRef.putData(uploadData, metadata: nil) { [self] (metadata, error) in
                if error != nil {
                    self.showAlert(title: AlertConstants.Error, message: error?.localizedDescription ?? AlertConstants.SomeThingWrong)
                    print("error")
                }
                else {
                    print("customLogoImage Updated successfully")
                }
            }
        }
        self.dismiss(animated: true)
    }
    
    func showAlertMessage(_ message: String) {
        self.showAlert(title: AlertConstants.Alert, message: message)
    }
    
    func showAlert() {
        if  let selectedLink = selectedLink, (selectedLink.linkID == 4 || selectedLink.linkID == 22 || selectedLink.linkID == 23 || selectedLink.linkID == 24 || selectedLink.linkID == 25)  {
            showAlertMessage(AlertConstants.customLink)
        }
        switch platform.lowercased() {
        
        case "whatsapp":
            showAlertMessage(AlertConstants.whatsappMessage)
            break
        case "linkedin":
            showAlertMessage(AlertConstants.linkedInAlertMessage)
            break
        case "twitter":
            showAlertMessage(AlertConstants.twitterMessage)
            break
        case "twitch":
            showAlertMessage(AlertConstants.twitchMessage)
            break
        case "telegram":
            showAlertMessage(AlertConstants.telegramMessage)
            break
        case "instagram":
            showAlertMessage(AlertConstants.instaGramMessage)
        case "youtube":
            showAlertMessage(AlertConstants.youtubeMessage)
            break
        case "facebook":
            showAlertMessage(AlertConstants.fbAlertMessage)
            break
        case "pinterest":
            showAlertMessage(AlertConstants.pintrestMessage)
            break
        case "vimeo":
            showAlertMessage(AlertConstants.vimeoMessage)
            break
//        case "reddit":
//             showAlertMessage(AlertConstants.redditMessage)
        case "snapchat":
            showAlertMessage(AlertConstants.snapchatMessage)
        case "tiktok":
            showAlertMessage(AlertConstants.tiktokMessage)
            break
        case "paypal":
            showAlertMessage(AlertConstants.paypalMessage)
            break
//        case "paylah":
//            showAlertMessage(AlertConstants.paylahMessage)
        case "calendly":
            showAlertMessage(AlertConstants.calendlyMessage)
        case "email":
            showAlertMessage(AlertConstants.email)
            break
        case "spotify":
            showAlertMessage(AlertConstants.spotify)
            break
        case "website":
            showAlertMessage(AlertConstants.customLink)
            break
        case "google":
            showAlertMessage(AlertConstants.customLink)
            break
        case "yelp":
            showAlertMessage(AlertConstants.customLink)
            break
        case "portfolio":
            showAlertMessage(AlertConstants.customLink)
            break
        case "shop":
            showAlertMessage(AlertConstants.customLink)
            break
        case "menu":
            showAlertMessage(AlertConstants.customLink)
            break
        case "catalog":
            showAlertMessage(AlertConstants.customLink)
            break
        case "open table":
            showAlertMessage(AlertConstants.customLink)
            break
        case "venmo":
            showAlertMessage(AlertConstants.customLink)
            break
        case "wi-fi":
            showAlertMessage(AlertConstants.customLink)
            break
//        case "custom link":
//            showAlertMessage(AlertConstants.customLink)
//            break
//        case "contact card","text":
//            showAlertMessage(AlertConstants.text)
//            break
        default:
            break
        }
    }
    
    //MARK: Button Actions
    
    @IBAction func isSharedSwitchAction(_ sender: UISwitch) {
    }
    @IBAction func editLinkNameBtn(_ sender: UIButton) {
        editLinkNameField.becomeFirstResponder()
    }
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        showAlert()
    }
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        if sender.title(for: .normal) == "Save"  {
            guard let linkValue = userNameField.text?.removeWhitespace() ,!linkValue.isEmpty else {
                self.showAlert(title: AlertConstants.Alert, message: "This field can not be empty")
                return
            }
            if self.validationOnTf(TF: userNameField) == false {
                showAlert(title: AlertConstants.Alert, message: "Please add valid data")
                return
            }
            var linkName = selectedLink?.name ?? ""
            if selectedLink?.linkID == 4 {
                self.saveLogoImageInDocumentDirectory(image: imgVu.image,url:customLogoImgUrl)
                linkName = editLinkNameField.text ?? "Custom Link"

            }
            else if selectedLink?.linkID == 22  {
                self.saveLogoImageInDocumentDirectory(image: imgVu.image,url:customLogo2ImgUrl)
                linkName = editLinkNameField.text ?? "Custom Link2"

            }
            else if selectedLink?.linkID == 23  {
                self.saveLogoImageInDocumentDirectory(image: imgVu.image,url:customLogo3ImgUrl)
                linkName = editLinkNameField.text ?? "Custom Link3"

            }
            else if selectedLink?.linkID == 24 {
                self.saveLogoImageInDocumentDirectory(image: imgVu.image,url:customLogo4ImgUrl)
                linkName = editLinkNameField.text ?? "Custom Link4"

            }
            else if selectedLink?.linkID == 25 {
                self.saveLogoImageInDocumentDirectory(image: imgVu.image,url:customLogo5ImgUrl)
                linkName = editLinkNameField.text ?? "Custom Link4"
            }
            if customLogoImageName == "" {
                delegate?.linkReceived(text: linkValue,platform: linkName,imageUrl: "", isShared:isSharedSwitch.isOn)
            } else {
                delegate?.linkReceived(text: linkValue,platform: linkName,imageUrl: customLogoImageName, isShared:isSharedSwitch.isOn)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func openBtnPressed(_ sender: Any) {
        
        guard let n = userNameField.text, !n.isEmpty else {
            showAlert(title: AlertConstants.Alert, message: "This value can not be empty.")
            return
        }
        
        let app = UIApplication.shared
        switch platform.lowercased() {
        
//        case "twitch":
//            let twitchURL = NSURL(string: n)
//            if (UIApplication.shared.canOpenURL(twitchURL! as URL)) {
//                // The Twitch app is installed, do whatever logic you need, and call -openURL:
//                UIApplication.shared.open(URL(string: "\(n)")!)
//            } else {
//                // The Twitch app is not installed. Prompt the user to install it!
//            }
        case "whatsapp":
            app.open(Applications.WhatsApp(), action: .send(abid: n, text: ""))
        case "instagram":
            app.open(Applications.Instagram(),action: .username(n))
        case "facebook":
            app.open(Applications.Facebook(),action: .profile)
        case "youtube":
            app.open(Applications.Youtube(),action: .open)
        case "twitter":
            app.open(Applications.Twitter(),action: .userHandle(n))
        
        case "linkedin":
            let webURL = URL(string: "\(n)")!
            
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)

//            let appURL = URL(string: "linkedin://profile/\(n)")!
//
//
//            if UIApplication.shared.canOpenURL(appURL) {
//                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
//            }
//
        case "snapchat":
            let username = n
            let appURL = URL(string: "snapchat://add/\(username)")!
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL) {
                application.open(appURL)
                
            } else {
                // if Snapchat app is not installed, open URL inside Safari
                let webURL = URL(string: "https://www.snapchat.com/add/\(username)")!
                application.open(webURL)
            }
        case "vimeo":
            app.open(Applications.Vimeo(),action: .open)
        case "tiktok":
            let installed = UIApplication.shared.canOpenURL(URL(string: "snssdk1233://user/profile/@\(n)")! as URL)
            if installed {
                UIApplication.shared.open(URL(string: "snssdk1233://user/profile/@\(n)")!)
            } else {
                UIApplication.shared.open(URL(string: "www.tiktok.com/\(n)")! as URL)
            }
            break
        case "telegram":
            if let url = URL(string: "tg://resolve?domain=\(n)") {
                UIApplication.shared.open(url)
            }
//        case "reddit":
//
//            let installed = UIApplication.shared.canOpenURL(URL(string: "reddit:")! as URL)
//            if installed {
//                UIApplication.shared.open(URL(string: "reddit://r/\(n)")!)
//            } else {
//                UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/reddit/id1064216828")! as URL)
//            }
            
        case "pinterest":
            app.open(Applications.Pinterest(),action: .user(name: n))
        case "email":
            self.sendEmail(n)
//            app.open(Applications.Mail(),action: .compose(email: .init(recipient: n, subject: "", body: "")))
//
        case "spotify":
            let installed = UIApplication.shared.canOpenURL(URL(string: "spotify:")! as URL)
            if installed {
                UIApplication.shared.open(URL(string: "\(n)")!)
            } else {
                UIApplication.shared.open(URL(string: "https://apps.apple.com/app/spotify-music/id324684580?mt=8")! as URL)
            }
        case "paypal":
            if let url = NSURL(string:n)?.absoluteURL,
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/paypal-mobile-cash/id283646709")! as URL)
            }
            
//        case "apple pay":
//            app.open(Applications.AppStore(),action: .app(id: "1160481993"))
//            UIApplication.shared.open(URL(string: "shoebox://")! as URL)
        case "custom link 1", "custom link 2", "custom link 3", "custom link 4", "custom link 5":
            let validUrlString = n.hasPrefix("https") ? n : n.hasPrefix("http") ? n : "https://\(n)"
            guard let url = URL(string: validUrlString) else {
                showAlert(title: AlertConstants.Alert, message: "Invalid Url")
                return
            }
            UIApplication.shared.open(url)
        case "website":
            let validUrlString = n.hasPrefix("https") ? n : "https://\(n)"
            guard let url = URL(string: validUrlString) else {
                showAlert(title: AlertConstants.Alert, message: "Invalid Url")
                return
            }
            //UIApplication.shared.open(url)
            UIApplication.shared.canOpenURL(url)
//        case "contact card":
//            if let url = URL(string: "tel://\(n)") {
//                UIApplication.shared.open(url)
//            }
//        case "apple":
//            app.open(Applications.Music(),action: .open)
//        case "text":
//            app.open(Applications.Messages(),action: .sms(phone: n))
        case "calendly":
            let validUrlString = n.hasPrefix("https") ? n : "https://\(n)"
            guard let url = URL(string: validUrlString) else {
                showAlert(title: AlertConstants.Alert, message: "Invalid Url")
                return
            }
            UIApplication.shared.open(url)
        default:
//            if let url = URL(string: "https://www.google.com/search?q=\(n)") {
//                UIApplication.shared.open(url)
//            }
            if let url = URL(string: n) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func dismissBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
        showTwoBtnAlert(title: AlertConstants.Alert, message: "Are you sure to delete link.", yesBtn: "Delete", noBtn: "Cancel") { [self] (delete) in
            if delete {
                if selectedLink?.linkID == 4 {
                    deleteLogoImageFromDocumentDirectory(url: customLogoImgUrl)
                    self.deleteCustomLinkImage(linkName: customLogoImageName)
                }
                else if selectedLink?.linkID == 22 {
                    deleteLogoImageFromDocumentDirectory(url: customLogo2ImgUrl)
                    self.deleteCustomLinkImage(linkName: customLogoImageName)
                }
                else if selectedLink?.linkID == 23 {
                    deleteLogoImageFromDocumentDirectory(url: customLogo3ImgUrl)
                    self.deleteCustomLinkImage(linkName: customLogoImageName)
                }
                else if selectedLink?.linkID == 24 {
                    deleteLogoImageFromDocumentDirectory(url: customLogo4ImgUrl)
                    self.deleteCustomLinkImage(linkName: customLogoImageName)
                }else if selectedLink?.linkID == 25 {
                    deleteLogoImageFromDocumentDirectory(url: customLogo4ImgUrl)
                    self.deleteCustomLinkImage(linkName: customLogoImageName)
                }
                
                deleteDelegate?.deleteLink(platform: self.platform)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    private func deleteCustomLinkImage(linkName:String?) {
        if let image = selectedLink?.image, image.removeWhitespace() != "" {
            var storageRef = storage.reference()
            storageRef = storage.reference(forURL: image)
            //Removes image from storage
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    // File deleted successfully
                }
            }
        }
    }

    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.5, height: 3.0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
    }
    
}
extension InsertLinkVC {
    
    func validationOnTf(TF: UITextField)->Bool {
        var value = false
        let id = selectedLink?.linkID
        if id == 4 || id == 22 || id == 23 || id == 24 || id == 25 {
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                    return value
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Link")
                    return value
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                return value
            }
        }
        
        switch selectedLink?.name?.lowercased() ?? "" {
            
        case "whatsapp":
            
            if let tfData = TF.text, !tfData.isEmpty {
                if isValidPhone(phone: tfData) == true {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Whatsapp Number")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
            
        case "phone":
            if let tfData = TF.text, !tfData.isEmpty {
                if isValidPhone(phone: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Phone Number")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "linkedin":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid LinkedIn URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
//        case "twitter":
//
//            if let tfData = TF.text, !tfData.isEmpty {
//                if isvalidURL(checkUrl: tfData) {
//                    value = true
//                } else {
//                    self.showAlert(title: "Alert", message: "Enter Valid Twitter URL")
//                }
//            } else {
//                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
//
//            }
        case "twitch":
            if let tfData = TF.text, tfData.isEmpty {
                showAlert(title: "Alert", message: "Enter Value in field")
            } else {
                value = true
            }
            
//        case "telegram":
//
//            if let tfData = TF.text, !tfData.isEmpty {
//                if isValidPhone(phone: tfData) {
//                    value = true
//                } else {
//                    self.showAlert(title: "Alert", message: "Enter Valid Telegram Number")
//                }
//            } else {
//                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
//
//            }
//        case "instagram":
//            if let tfData = TF.text, !tfData.isEmpty {
//                if isvalidURL(checkUrl: tfData) {
//                    value = true
//                } else {
//                    self.showAlert(title: "Alert", message: "Enter Valid Instagram URL")
//                }
//            } else {
//                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
//
//            }
        case "youtube":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Youtube URL")
                    
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "facebook":
            
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Facebook URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
            break
        case "pinterest":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                    
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Pinterest URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "menu", "spotify", "instagram", "telegram", "twitter":
            if let tfData = TF.text, tfData.isEmpty {
                showAlert(title: "Alert", message: "Enter Value in field")
            } else{
                value = true
            }
        case "reddit":
            if let tfData = TF.text, tfData.isEmpty {
                showAlert(title: "Alert", message: "Enter Value in field")
            } else {
                value = true
            }
            
        case "snapchat":
            if let tfData = TF.text, tfData.isEmpty  {
                showAlert(title: "Alert", message: "Enter Value in field")
            } else {
                value = true
            }
            
        case "tiktok":
            if let tfData = TF.text, tfData.isEmpty {
                showAlert(title: "Alert", message: "Enter Value in field")
            } else {
                value = true
            }
            
        case "paypal":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid paypal URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "paylah":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid paylah URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
            }
        case "calendly":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Calendly URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "email":
            
            if let tfData = TF.text, !tfData.isEmpty {
                if isValidEmail(email: tfData) == true {
                    value = true
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid email address")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
            
        case "my pet":
            
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                    
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid My Pet URL")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "custom link","website", "catalogo","custom link 1", "custom link 2","custom link 3","custom link 4","custom link 5","venmo","wi-fi", "open table", "yelp", "catalog", "shop", "portfolio", "google", "vimeo":
            if let tfData = TF.text, !tfData.isEmpty {
                if isvalidURL(checkUrl: tfData) {
                    value = true
                    
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Link")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
        case "contact card","text":
            
            if let tfData = TF.text, !tfData.isEmpty {
                if isValidPhone(phone: tfData) {
                    value = true
                    
                } else {
                    self.showAlert(title: "Alert", message: "Enter Valid Number")
                }
            } else {
                showAlert(title: AlertConstants.Alert, message: AlertConstants.emptyFieldAlert)
                
            }
            break
        default:
            break
        }
        
        return value
    }
    
}
