

import UIKit
import CropViewController
import iOSDropDown
import FirebaseStorage
import CodableFirebase

class EditProfileCell: UICollectionViewCell {
    @IBOutlet weak var outerVu: UIView!
    @IBOutlet weak var imgVu: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
}

class AddLinksVC: BaseClass,TextBackProtocol,getDate,LinkAdded,LinkDeleted, MapAddress {
    @IBOutlet weak var saveBtn: UIButton! {didSet{self.addShadowtoBtn(btn: saveBtn)}}
    @IBOutlet weak var collectionVu: UICollectionView!
    
    @IBOutlet weak var cancelBtn: UIButton! {didSet{self.addShadowtoBtn(btn: cancelBtn)}}
    
    var linkChanged = false
    var isLogo = false
    var index = -1
    var headerIndex : IndexPath = IndexPath(item: 0, section: 0)
    var profilePicture = UIImage(named: "ic_image_placeholder")
    var coverPicture = UIImage(named: "ic_image_placeholder")
    var logoPic = UIImage(named: "img")
    
    var headerHeight : CGFloat = 670.0
    var headerTotalHeight : CGFloat = 670.0
    var lblHeight : CGFloat = 00.0
    var bioText = "Bio"
    var profileUrl = ""
    var coverUrl = ""
    var logoUrl = ""
    
    var nameChanged = false
    var newName = ""
    var bioChanged = false
    //    var newBioText = ""
    var profileChanged = false
    var coverChanged = false
    var newProfile = UIImage(named: "ic_image_placeholder")
    var dobChanged = false
    var newDob = "Date of Birth"
    var phoneChanged = false
    var companyChanged = false
    var newPhone = ""
    var newCompany = ""
    var newAddress = ""
    
    var userDetails : User?
    let storage = Storage.storage()
    
    //==========================================
    var isLogoRemoved = false
    var isProfilePicRemoved = false
    var isCoverPicRemoved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionVu.delegate = self
        collectionVu.dataSource = self
        setProfile()
        setCover()
        
        //getAllLinks()
        getAllLinksFromJsonFile()
        self.checkLocationService()

    }
    
    // MARK: Delegates Received
    func addressSelected(address: String) {
        let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView

        header?.addressTF.text = address
    }
    //==========================================
    func linkReceived(text: String,platform: String, imageUrl: String?, isShared:Bool) {
        
        if userLinks == nil {
            userLinks = []
        }
        userAllLinks?[index].value = text
        userAllLinks?[index].name = platform
        userAllLinks?[index].isShared = isShared
        if let imageUrl = imageUrl, imageUrl != "" {
            userAllLinks?[index].image = imageUrl
        }
        var found = false
        for i in 0..<(userLinks ?? []).count {
            if userLinks?[i].linkID == userAllLinks?[index].linkID {
                userLinks?[i] = (userAllLinks?[index])!
                found = true
                break
            }
        }
        
        if !found {
            userLinks?.append((userAllLinks?[index])!)
        }
        linkChanged = true
        self.collectionVu.reloadData()
    }
    
    func deleteLink(platform: String) {
        
        for i in 0..<(userLinks ?? []).count {
            if userLinks?[i].linkID == userAllLinks?[index].linkID {
                userLinks?.remove(at: i)
                userAllLinks?[index].value = ""
                let selectedLink = userAllLinks?[index]
                if selectedLink?.linkID == 4 {
                    userAllLinks?[index].name = "Custom Link 1"
                }
                else if selectedLink?.linkID == 22 {
                    userAllLinks?[index].name = "Custom Link 2"
                }
                else if selectedLink?.linkID == 23 {
                    userAllLinks?[index].name = "Custom Link 3"
                }
                else if selectedLink?.linkID == 24 {
                    userAllLinks?[index].name = "Custom Link 4"
                }
                else if selectedLink?.linkID == 25 {
                    userAllLinks?[index].name = "Custom Link 5"
                }
                break
            }
        }
        linkChanged = true
        collectionVu.reloadData()
    }
    
    func textReceived(text: String) {
        
        bioText = text
        bioChanged = true
        bioText = bioText.removingAllExtraNewLines

        if bioText == "" || bioText.isEmpty {
            let height = "Bio".getStringHeight(constraintedWidth: (collectionVu.frame.width - 30) , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + height
            
        } else {
            let height = bioText.getStringHeight(constraintedWidth: collectionVu.frame.width , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + height
        }
        collectionVu.reloadData()
    }
    
    func getSelectedDate(_ date: String) {
        newDob = date
        dobChanged = true
        collectionVu.reloadData()
        if date == "Date of Birth" {
            let param : [String:String?] = [
                "id" : getUserId(),
                "dob": "",
            ]
            APIManager.updateUserProfile(param as APIManager.dictionaryParameter) { [self] (success) in
                self.stopLoading()
                if success {
                    print("updated")
                }
            }
        } else {
            let param : [String:String?] = [
                "id" : getUserId(),
                "dob": date,
            ]
            APIManager.updateUserProfile(param as APIManager.dictionaryParameter) { [self] (success) in
                self.stopLoading()
                if success {
                    
                }
            }
            
        }
        
        
        
    }
    
    // MARK:- Ovveriden Methods
    //==========================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addText" {
            if let vc = segue.destination as? AddTextViewController {
                vc.delegate = self
                if bioChanged {
                    vc.bioText = bioText
                } else {
                    vc.bioText = userDetails?.bio ?? ""
                }
            }
        } else if segue.identifier == "showDate" {
            if let vc = segue.destination as? DateVC {
                vc.delegate = self
                if dobChanged {
                    vc.oldDate = newDob
                } else {
                    vc.oldDate = userDetails?.dob ?? ""
                }
            }
        } else if segue.identifier == "addNewLinks" {
            let vc = segue.destination as? InsertLinkVC
            
            let x = userAllLinks?[index].name?.capitalized
            vc?.platform = x ?? "No Name"
            vc?.text = userAllLinks?[index].value ?? ""
            vc?.img = userAllLinks?[index].image ?? ""
            vc?.selectedLink = userAllLinks?[index]
            vc?.deleteDelegate = self
            vc?.delegate = self
        }
    }
    
    override func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    print("crop img fun")
        var storageRef = storage.reference()
        if isLogo {
            logoPic = image
            storageRef = storage.reference().child("logoImg:\(getUserId()).png")
            
        }
        if profileChanged{
            profilePicture = image
            storageRef = storage.reference().child("profilePic:\(getUserId()).png")
            imgChache.setObject(image, forKey: storageRef)
            
        }
        if coverChanged{
            coverPicture = image
            storageRef = storage.reference().child("coverPic:\(getUserId()).png")
            imgChache.setObject(image, forKey: storageRef)
        }
        
        startLoading()
        
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            storageRef.putData(uploadData, metadata: nil) { [self] (metadata, error) in
                if error != nil {
                    self.stopLoading()
                    self.showAlert(title: AlertConstants.Error, message: error?.localizedDescription ?? AlertConstants.SomeThingWrong)
                    print("error")
                } else {
                    
                    var dict = [String:String]()
                    if isLogo {
                        logoUrl = "\(storageRef)"
                        //userDetails?.logoUrl = logoUrl
                        dict = ["id":getUserId(),
                                "logoUrl":logoUrl]
                    }
                    if profileChanged{
                        profileUrl = "\(storageRef)"
                        userDetails?.profileUrl = profileUrl
                        dict = ["id":getUserId(),
                                "profileUrl":profileUrl]
                        NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["url":profileUrl])
                    }
                    if coverChanged{
                        coverUrl = "\(storageRef)"
                        userDetails?.coverUrl = coverUrl
                        dict = ["id":getUserId(),
                                "coverUrl":coverUrl]
                        NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["url":coverUrl])
                    }
                    APIManager.updateUserProfile(dict) { [self] (success) in
                        saveUserToDefaults(userDetails!)
                        stopLoading()
                        print("Saved profile with url",dict)
                    }
                }
            }
        }
        
        collectionVu.reloadData()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- Selector Methods
    //==========================================
    /*
     Added click on bio label
     */
    @objc func lblTapped (sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "addText", sender: self)
    }
    
    //    @objc func logoImgTapped(_ button:UIButton){
    //
    //        resignFirstResponder()
    //        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
    //            print("Button capture")
    //            imagePicker.delegate = self
    //            imagePicker.sourceType = .savedPhotosAlbum
    //            imagePicker.allowsEditing = false
    //            isLogo = true
    //            present(imagePicker, animated: true, completion: nil)
    //        }
    //
    //    }
    
    @objc func imgVuTapped (sender: UITapGestureRecognizer){
        
        resignFirstResponder()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button profile capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            isLogo = false
            coverChanged = false
            profileChanged = true
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    @objc func imgcoverVuTapped (sender: UITapGestureRecognizer){
        
        resignFirstResponder()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button cover capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            isLogo = false
            profileChanged = false
            coverChanged = true
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
  
    @objc func editFieldTapped (sender: UITapGestureRecognizer) {
        let header = collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: headerIndex) as? AddLinksReusableView
        guard let view = sender.view else {
            return
        }
        
        switch view {
        case header?.userNameVu:
            header?.nameTF.becomeFirstResponder()
     
        case header?.companyVu:
            header?.companyTF.becomeFirstResponder()
        default:
            print(sender.debugDescription)
        }
    }
    
    @objc final private func didEndEditing(textField: UITextField) {
        switch textField.tag {
        case 11:
            nameChanged = true
            newName = textField.text ?? "Name"
        case 33:
            phoneChanged = true
            newPhone = textField.text ?? "Phone"
        case 44:
            companyChanged = true
            newCompany = textField.text ?? "Company"
            
        default:
            break
        }
    }
    
    @objc func editUsername(_ button:UIButton){
        
        resignFirstResponder()
        let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView
        
        
        switch button.tag {
        case 1:
            header?.nameTF.becomeFirstResponder()
        case 2:
            performSegue(withIdentifier: "addText", sender: self)
        case 3:
            header?.phoneTF.becomeFirstResponder()
        case 4:
            header?.companyTF.becomeFirstResponder()
        default:
            break
            //Do nothing
            
        }
        
    }
    
    @objc func showDateVu(_ button:UIButton){
        performSegue(withIdentifier: "showDate", sender: self)
    }
    
    // MARK:- Actions
    //==========================================
    
    //TODO: saveBtnPressed
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        resignFirstResponder()
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        
        startLoading()
        if linkChanged {
            
            APIManager.updateUserLinks() { [self] (success) in
                self.stopLoading()
                if !success {
                    self.showAlert(title: AlertConstants.Error, message: "User Link Could not be saved, please try again.")
                    return
                }
            }
        }
        
        let header = collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: headerIndex) as? AddLinksReusableView
        
        guard let name = header?.nameTF.text, !name.isEmpty,
              let bio = bioChanged ? bioText : userDetails?.bio,
//              let address = header?.addressTF.text,
//              let date = dobChanged ? newDob : userDetails?.dob,
//              let phone = header?.phoneTF.text, !phone.isEmpty,
              let company = header?.companyTF.text, !company.isEmpty
        else {
            self.stopLoading()
            if linkChanged {
                showAlert(title: "Alert", message: "Links updated")
            } else {
                showAlert(title: "Alert", message: AlertConstants.AllFieldNotFilled)
            }
            return
        }
        
        let param : [String:String?] = [
            "id" : getUserId(),
            "name": name,
            "bio": bio,
            "company": company,
            "profileUrl": profileUrl,
            "coverUrl": coverUrl
        ]
        
        APIManager.updateUserProfile(param as APIManager.dictionaryParameter) { [self] (success) in
            self.stopLoading()
            if success {

                userDetails?.name = name
                userDetails?.profileUrl = profileUrl
                userDetails?.coverUrl = coverUrl
                userDetails?.bio = bio
//                userDetails?.phone = phone
//                userDetails?.dob = date
//                userDetails?.address = address
                userDetails?.company = company
                userDetails?.fcmToken = getFCM()
                
                NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["name": name,"url":profileUrl])
                NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["name": name,"url":coverUrl])

                self.saveUserToDefaults(userDetails!)
                
                profileChanged = false
                coverChanged = false
                nameChanged = false
                bioChanged = false
                dobChanged = false
                phoneChanged = false
                companyChanged = false
                
                self.showAlert(title: AlertConstants.Success, message: "Profile updated successfully") {
                    
                    NotificationCenter.default.post(name: Notification.Name("changeRootVC"), object: nil, userInfo: ["VCName":"DashBoardVC"])
                }
            } else {
                self.showAlert(title: AlertConstants.Error, message: "Profile could not be updated")
            }
        }
    }
    
    //TODO: cancelBtnPressed
    @IBAction func cancelBtnPressed(_ sender: Any) {
        profileChanged = false
        coverChanged = false
        nameChanged = false
        bioChanged = false
        dobChanged = false
        phoneChanged = false
        linkChanged = false
        companyChanged = false
        
        NotificationCenter.default.post(name: Notification.Name("changeRootVC"), object: nil, userInfo: ["VCName":"DashBoardVC"])
        
    }
    
    func setProfileRemoveButton(image: UIImage, header: AddLinksReusableView?) {
        if (image == UIImage(named: "ic_image_placeholder")) {
            header?.removeProfileImg.isHidden = true
        }
        else {
            header?.removeProfileImg.isHidden = false
        }
    }
    func setCoverRemoveButton(image: UIImage, header: AddLinksReusableView?) {
        if (image == UIImage(named: "ic_image_placeholder")) {
            header?.removecoverImg.isHidden = true
        }
        else {
            header?.removecoverImg.isHidden = false
        }
    }
    
    @objc func removeProfileTapped (_ button: UIButton) {
        profileUrl = ""
        profileChanged = true
        self.isProfilePicRemoved = true
        self.showTwoBtnAlert(title: AlertConstants.Alert, message: "Do you want to remove?", yesBtn: "Yes", noBtn: "No") { isYes in
            if isYes{
                self.profilePicture = UIImage(named: "ic_image_placeholder")
                let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView
                header?.profileImg.image = UIImage(named: "ic_image_placeholder")
                header?.removeProfileImg.isHidden = true
                self.updateProfileImages()
            }
        }
    }
    @objc func removeCoverTapped (_ button: UIButton) {
        coverUrl = ""
        coverChanged = true
        self.isCoverPicRemoved = true
        self.showTwoBtnAlert(title: AlertConstants.Alert, message: "Do you want to remove?", yesBtn: "Yes", noBtn: "No") { isYes in
            if isYes{
                self.coverPicture = UIImage(named: "ic_image_placeholder")
                let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView
                header?.coverImg.image = UIImage(named: "ic_image_placeholder")
                header?.removecoverImg.isHidden = true
                self.updateCoverImages()
            }
        }
    }
    
    func updateProfileImages() {
        //let image = UIImage(named: "ic_image_placeholder")
        profileChanged = true
        var dict = [String:String]()
        var storageRef = storage.reference()
        if isProfilePicRemoved {
            storageRef = storage.reference().child("profilePic:\(getUserId()).png")
            
            //imgChache.setObject(profilePicture!, forKey: storageRef)
            profileUrl = ""
            imgChache.removeObject(forKey: storageRef)
            
            userDetails?.profileUrl = ""
            
            let user = readUserData()
            dict = ["id": (user?.id)!,
                    "profileUrl":""]
            
            
            NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["url":profileUrl])
        }
        
        startLoading()
        APIManager.updateUserProfile(dict) { [self] (success) in
            saveUserToDefaults(userDetails!)
            stopLoading()
            print("Saved profile with url",dict)
        }
    }
    func updateCoverImages() {
        //let image = UIImage(named: "ic_image_placeholder")
        coverChanged = true
        var dict = [String:String]()
        var storageRef = storage.reference()
        if isCoverPicRemoved {
            storageRef = storage.reference().child("coverPic:\(getUserId()).png")
            //imgChache.setObject(profilePicture!, forKey: storageRef)
            coverUrl = ""
            imgChache.removeObject(forKey: storageRef)
            
            userDetails?.coverUrl = ""
            
            let user = readUserData()
            dict = ["id": (user?.id)!,
                    "coverUrl":""]
            
            
            NotificationCenter.default.post(name: Constants.profileUpdateNotif, object: nil, userInfo: ["url":coverUrl])
        }
        startLoading()
        APIManager.updateUserProfile(dict) { [self] (success) in
            saveUserToDefaults(userDetails!)
            stopLoading()
            print("Saved cover with url",dict)
        }
    }
    
    //MARK: Get All Links from json file
    func getAllLinksFromJsonFile() {
        if let url = Bundle.main.url(forResource: "AllSocialLinks", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let allLinksData = try decoder.decode(AllLinks.self, from: data)
                handleAllLinks(links: allLinksData.allSocialLinks)
                print(allLinksData)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    func handleAllLinks(links: [Links]?) {
        var tempLinks = links
        if let addIndex = tempLinks?.firstIndex(where: {$0.name == "Add New"}) {
            tempLinks?.remove(at: addIndex)
        }
        
        for i in 0..<(tempLinks?.count ?? 0) {
            for j in 0..<(userLinks?.count ?? 0) {
                if tempLinks?[i].linkID == userLinks?[j].linkID{
                    tempLinks?[i].value = userLinks?[j].value
                    tempLinks?[i].name = userLinks?[j].name
                    tempLinks?[i].image = userLinks?[j].image
                }
            }
        }
        userAllLinks = tempLinks
        collectionVu.reloadData()
    }
    // MARK: Get All Links from firebase
    //==========================================
    func getAllLinks() {
        
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        
        startLoading()
        APIManager.getAllLinks() { [self] (data) in
            if data == nil {
                print("Nil Links are Returned")
            } else {
                var links = data
                
                if let addIndex = links?.firstIndex(where: {$0.name == "Add New"}) {
                    links?.remove(at: addIndex)
                }
                
                
                print("Data Found in links",data as Any)
                
                for i in 0..<(links?.count ?? 0) {
                    for j in 0..<(userLinks?.count ?? 0) {
                        if links?[i].name == userLinks?[j].name {
                            links?[i].value = userLinks?[j].value
                        }
                    }
                }
                userAllLinks = links
                
            }
            
            DispatchQueue.main.async {
                self.collectionVu.reloadData()
                self.stopLoading()
            }
            
        } error: { [self] err in
            stopLoading()
            showAlert(title: AlertConstants.Error, message: err)
        }
    }
    
    func setProfile() {
        
        userDetails = readUserData()
        
        if let text = userDetails?.bio, text == "" || text.isEmpty {
            let height = "Bio".getStringHeight(constraintedWidth: (collectionVu.frame.width - 30) , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + height
            
        } else {
            let height = userDetails?.bio?.getStringHeight(constraintedWidth: collectionVu.frame.width , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + (height ?? 20)
        }
        collectionVu.reloadData()
        profileUrl = userDetails?.profileUrl ?? ""
        //logoUrl = userDetails?.logoUrl ?? ""
        
        //        var url = URL(string: profileUrl)
        
        DispatchQueue.main.async { [self] in
            var ref = storage.reference()
            let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView
            
            if profileUrl != "" {
                ref = storage.reference(forURL: profileUrl)
                if let cacheImg = imgChache.object(forKey: ref) as? UIImage {
                    header?.profileImg.image = cacheImg
                    self.profilePicture = cacheImg
                    self.setProfileRemoveButton(image: cacheImg, header: header)
                } else {
                    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                            // Uh-oh, an error occurred!
                        } else {
                            if let img = UIImage(data: data!) {
                                imgChache.setObject(img, forKey: ref)
                                header?.profileImg.image = img
                                self.profilePicture = img
                                self.setProfileRemoveButton(image: img, header: header)
                            }
                        }
                    }
                }
            }
            
            if logoUrl != "" {
                
                ref = storage.reference(forURL: logoUrl)
                
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            //header?.logoBtn.setImage(img, for: .normal)
                            self.logoPic = img
                        }
                    }
                }
                
            }
        }
        
        //        profilePicture =  userProfileInDefault?["profileUrl"] as? String
    }
    
    func setCover() {
        
        userDetails = readUserData()
        
        if let text = userDetails?.bio, text == "" || text.isEmpty {
            let height = "Bio".getStringHeight(constraintedWidth: (collectionVu.frame.width - 30) , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + height
            
        } else {
            let height = userDetails?.bio?.getStringHeight(constraintedWidth: collectionVu.frame.width , font: UIFont.systemFont(ofSize: 22.5))
            headerTotalHeight = headerHeight + (height ?? 20)
        }
        collectionVu.reloadData()
        coverUrl = userDetails?.coverUrl ?? ""
        //logoUrl = userDetails?.logoUrl ?? ""
        
        //        var url = URL(string: profileUrl)
        
        DispatchQueue.main.async { [self] in
            var ref = storage.reference()
            let header = self.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self.headerIndex)) as? AddLinksReusableView
            
            if coverUrl != "" {
                ref = storage.reference(forURL: coverUrl)
                if let cacheImg = imgChache.object(forKey: ref) as? UIImage {
                    header?.coverImg.image = cacheImg
                    self.coverPicture = cacheImg
                    self.setCoverRemoveButton(image: cacheImg, header: header)
                } else {
                    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                            // Uh-oh, an error occurred!
                        } else {
                            if let img = UIImage(data: data!) {
                                imgChache.setObject(img, forKey: ref)
                                header?.coverImg.image = img
                                self.coverPicture = img
                                self.setCoverRemoveButton(image: img, header: header)
                            }
                        }
                    }
                }
            }
            
            if logoUrl != "" {
                
                ref = storage.reference(forURL: logoUrl)
                
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            //header?.logoBtn.setImage(img, for: .normal)
                            self.logoPic = img
                        }
                    }
                }
                
            }
        }
        
        //        profilePicture =  userProfileInDefault?["profileUrl"] as? String
    }
    
    func dropDownproperties(dropDown: DropDown, placeHolder: String, listArray: [String]) {
        dropDown.text = placeHolder
        dropDown.optionArray = listArray
        dropDown.arrowColor = .black
        dropDown.isSearchEnable = false
        dropDown.selectedRowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        dropDown.rowHeight = 50
        dropDown.listHeight = 200
        
    }
    
    //MARK: Save image from firebase to document directory
    private func saveCustomLinkImage(link: Links) {
        let storageRef = Storage.storage().reference().child(link.image!)
        storageRef.getData(maxSize: 1 * 1024 * 8024) { data, error in
            DispatchQueue.main.async() {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let img = UIImage(data: data!) {
                        let linkPath = self.getLinkImgLocalPath(linkID: "LinkID\((link.linkID)!)")
                        
                        self.saveLogoImageInDocumentDirectory(image: img, url: linkPath)
                        self.collectionVu.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: Collection View Delegates
extension AddLinksVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
        
        let link = userAllLinks?[indexPath.row]
        
        cell.imgVu.image = nil
        cell.lbl.text = link?.name ?? ""
        cell.imgVu.borderWidthV = 0
        
        if link?.value != "" && link?.value != nil {
            cell.checkMark.isHidden = false
        } else {
            cell.checkMark.isHidden = true
        }
        
        cell.imgVu.image = UIImage(named: link?.name?.lowercased() ?? "")
        
        if let link = link,
           let linkValue = link.value,
           link.image != nil,
           linkValue != "",
           (link.linkID == 4 || link.linkID == 22 || link.linkID == 23 || link.linkID == 24 || link.linkID == 25)  {
            cell.imgVu.layer.cornerRadius = 10
            
            cell.imgVu.layer.masksToBounds = true
        }
        
        if link?.linkID == 4 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogoImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderWidthV = 1
                    cell.imgVu.borderColorV = UIColor.black
                } else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                    //cell.imgVu.loadGif(name: "Custom Link 1")
                    self.saveCustomLink1Image(link: link!)
                }
            } else {
                //                    if let cacheImg = imgChache.object(forKey: "CustomLink1" as AnyObject) as? Data {
                //                        cell.imgVu.loadGifWithData(data: cacheImg)
                //                    }
                //cell.imgVu.loadGif(name: "Custom Link 1")
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
            }
        } else if link?.linkID == 22 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo2ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderWidthV = 1
                    cell.imgVu.borderColorV = UIColor.black
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                    // cell.imgVu.loadGif(name: "Custom Link 2")
                    self.saveCustomLink2Image(link: link!)
                }
            }else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
                //cell.imgVu.loadGif(name: "Custom Link 2")
            }
        }
        
        if link?.linkID == 23 {
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo3ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderWidthV = 1
                    cell.imgVu.borderColorV = UIColor.black
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                    //cell.imgVu.loadGif(name: "Custom Link 3")
                    self.saveCustomLink3Image(link: link!)
                }
            }  else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
                //cell.imgVu.loadGif(name: "Custom Link 3")
            }
        }
        if link?.linkID == 24 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo4ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderWidthV = 1
                    cell.imgVu.borderColorV = UIColor.black
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                    //cell.imgVu.loadGif(name: "Custom Link 4")
                    self.saveCustomLink4Image(link: link!)
                }
            } else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
                //cell.imgVu.loadGif(name: "Custom Link 4")
            }
        }
        if link?.linkID == 25 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo5ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderWidthV = 1
                    cell.imgVu.borderColorV = UIColor.black
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                    self.saveCustomLink5Image(link: link!)
                }
            } else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
                //cell.imgVu.loadGif(name: "Custom Link 5")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds
        let width = (size.width / 3) - 45
        let height = width + 25
        return CGSize(width: width, height: height) // viewcollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 17, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        
        // Can edit link if already added
        let filteredLink =  userLinks?.filter { $0.linkID == userAllLinks?[index].linkID }
        if (filteredLink?.count ?? 0) > 0 {
            performSegue(withIdentifier: "addNewLinks", sender: self)
        } else {
            //Custom links can only be added if package is life time
            if let linkID = userAllLinks?[index].linkID, (linkID == 4 || linkID == 22 || linkID == 23 || linkID == 24 || linkID == 25) {
                if purchasedSubscription == .lifeTime {
                    performSegue(withIdentifier: "addNewLinks", sender: self)
                } else {
                    self.showInAppPurchaseAlert()
                }
            }
            //In free mode links can not be added more than 3.
            else if (purchasedSubscription == .none && (userLinks?.count ?? 0) >= 3) {
                self.showInAppPurchaseAlert()
            }
            //In monthly package links can not be added more than 6
            else if (purchasedSubscription == .monthly && (userLinks?.count ?? 0) >= 6) {
                self.showInAppPurchaseAlert()
            }
            //In yearly package all links can be added except custom links
            else {
                performSegue(withIdentifier: "addNewLinks", sender: self)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userAllLinks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: CGFloat(headerTotalHeight))
    }
    
    //MARK: Collection Headerview
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AddLinksReusableView", for: indexPath) as? AddLinksReusableView else {
            fatalError("Invalid view type")
        }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            
            headerIndex = indexPath
            print(indexPath)
            let numberOfPostsViewSelector : Selector = #selector(self.imgVuTapped)
            let viewPostsViewGesture = UITapGestureRecognizer(target: self, action: numberOfPostsViewSelector)
            let numberOfPostsViewSelector2 : Selector = #selector(self.imgcoverVuTapped)
            let viewPostsViewGesture2 = UITapGestureRecognizer(target: self, action: numberOfPostsViewSelector2)
            headerView.profileImg.isUserInteractionEnabled = true
            headerView.addcoverImg.isUserInteractionEnabled = true
            viewPostsViewGesture.numberOfTapsRequired = 1
            viewPostsViewGesture.delaysTouchesBegan = true
            viewPostsViewGesture2.numberOfTapsRequired = 1
            viewPostsViewGesture2.delaysTouchesBegan = true
            headerView.profileImg.addGestureRecognizer(viewPostsViewGesture)
            headerView.addcoverImg.addGestureRecognizer(viewPostsViewGesture2)
            headerView.nameTF.addTarget(self, action: #selector(didEndEditing(textField:)), for: .editingDidEnd)
            
            headerView.companyTF.addTarget(self, action: #selector(didEndEditing(textField:)), for: .editingDidEnd)
            headerView.nameTF.delegate = self
            headerView.companyTF.delegate = self
            
            headerView.addProfileImg.addTarget(self, action: #selector(imgVuTapped(sender:)), for: .touchUpInside)
            headerView.removeProfileImg.addTarget(self, action: #selector(removeProfileTapped(_:)), for: .touchUpInside)
            headerView.addcoverImg.addTarget(self, action: #selector(imgcoverVuTapped(sender:)), for: .touchUpInside)
            headerView.removecoverImg.addTarget(self, action: #selector(removeCoverTapped(_:)), for: .touchUpInside)
            let userNameSelector : Selector = #selector(self.editFieldTapped)
            let userNameViewGesture = UITapGestureRecognizer(target: self, action: userNameSelector)
            
//            let addressSelector : Selector = #selector(self.addressTapped)
//            let addressVuGesture = UITapGestureRecognizer(target: self, action: addressSelector)
           
            headerView.userNameVu.addGestureRecognizer(userNameViewGesture)
            
            headerView.companyVu.addGestureRecognizer(userNameViewGesture)
            
          
            
            let lblSelector : Selector = #selector(self.lblTapped)
            let lblSelectorGesture = UITapGestureRecognizer(target: self, action: lblSelector)
            headerView.bioLbl.isUserInteractionEnabled = true
            
            lblSelectorGesture.numberOfTapsRequired = 1
            lblSelectorGesture.delaysTouchesBegan = true
            headerView.bioLbl.addGestureRecognizer(lblSelectorGesture)
            
            headerView.editUsernameBtn.addTarget(self, action: #selector(editUsername(_:)), for: .touchUpInside)
            
            headerView.editBioBtn.addTarget(self, action: #selector(editUsername(_:)), for: .touchUpInside)

            if nameChanged {
                headerView.nameTF.text = newName
            } else {
                headerView.nameTF.text = userDetails?.name ?? "Name"
            }
            
            if bioChanged {
                headerView.bioLbl.text = bioText
            } else {
                
                if let text = userDetails?.bio, text == "" || text.isEmpty {
                    headerView.bioLbl.text = "Bio"
                } else {
                    headerView.bioLbl.text = userDetails?.bio
                }
            }
          
            if companyChanged {
                headerView.companyTF.text = newCompany
            } else {
                headerView.companyTF.text = userDetails?.company ?? ""
            }
            
            headerView.profileImg.image = profilePicture
            headerView.coverImg.image = coverPicture
            self.setProfileRemoveButton(image: profilePicture!, header: headerView)
            self.setCoverRemoveButton(image: coverPicture!, header: headerView)
          
        default:
            assert(false, "Invalid element type")
        }
        return headerView
    }
}

extension AddLinksVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //        if purchasedSubscription == .none {
        //            textField.resignFirstResponder()
        //            showInAppPurchaseAlert()
        //        }
        /*
         if textField.tag == 44 {
         if appVersion != .allFeatures {
         textField.resignFirstResponder()
         showInAppPurchaseAlert()
         }
         } */
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

//extension AddLinksVC {
//    private func saveCustomLink1Image(link: Links) {
//        // Custom link Image 1
//        let storageRef = self.storage.reference().child("customLogoImg:\(self.getUserId()).png")
//        if link.image == "\(storageRef)" {
//            DispatchQueue.main.async() {
//                storageRef.getData(maxSize: 1  * 1024 * 8024) { data, error in
//                    
//                    if let error = error {
//                        print(error.localizedDescription)
//                        // Uh-oh, an error occurred!
//                    } else {
//                        if let img = UIImage(data: data!) {
//                            self.customLogoImg = img
//                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogoImgUrl)
//                            self.stopLoading()
//                            self.collectionVu.reloadData()
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
extension AddLinksVC {
    
    //MARK: Save custom link images
    private func saveCustomLink1Image(link: Links) {
        // Custom link Image 1
        let storageRef = self.storage.reference().child("customLogoImg:\(self.getUserId()).png")
        if link.image == "\(storageRef)" {
            DispatchQueue.main.async() {
                storageRef.getData(maxSize: 1 * 1024 * 8024) { data, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            self.customLogoImg = img
                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogoImgUrl)
                            self.stopLoading()
                            self.collectionVu.reloadData()
                        }
                    }
                }
            }
        }
    }
    private func saveCustomLink2Image(link: Links) {
        // Custom link Image 2
        let storageRef2 = self.storage.reference().child("customLogoImg2:\(self.getUserId()).png")
        if link.image == "\(storageRef2)" {
            DispatchQueue.main.async() {
                storageRef2.getData(maxSize: 1 * 1024 * 8024) { data, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            self.customLogoImg2 = img
                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo2ImgUrl)
                            self.stopLoading()
                            self.collectionVu.reloadData()
                        }
                    }
                }
            }
        }
    }
    private func saveCustomLink3Image(link: Links) {
        // Custom link Image 3
        let storageRef3 = self.storage.reference().child("customLogoImg3:\(self.getUserId()).png")
        if link.image == "\(storageRef3)" {
            DispatchQueue.main.async() {
                storageRef3.getData(maxSize: 1 * 1024 * 8024) { data, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            self.customLogoImg3 = img
                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo3ImgUrl)
                            self.stopLoading()
                            self.collectionVu.reloadData()
                        }
                    }
                }
            }
        }
    }
    private func saveCustomLink4Image(link: Links) {
        // Custom link Image 4
        let storageRef4 = self.storage.reference().child("customLogoImg4:\(self.getUserId()).png")
        if link.image == "\(storageRef4)" {
            DispatchQueue.main.async() {
                storageRef4.getData(maxSize: 1 * 1024 * 8024) { data, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            self.customLogoImg4 = img
                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo4ImgUrl)
                            self.stopLoading()
                            self.collectionVu.reloadData()
                        }
                    }
                }
            }
        }
    }
    private func saveCustomLink5Image(link: Links) {
        // Custom link Image 4
        let storageRef4 = self.storage.reference().child("customLogoImg5:\(self.getUserId()).png")
        if link.image == "\(storageRef4)" {
            DispatchQueue.main.async() {
                storageRef4.getData(maxSize: 1 * 1024 * 8024) { data, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            self.customLogoImg5 = img
                            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo5ImgUrl)
                            self.stopLoading()
                            self.collectionVu.reloadData()
                        }
                    }
                }
            }
        }
    }
}
