

import UIKit
import CodableFirebase
import Firebase
import AlamofireImage
import FirebaseStorage

class ProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVu: UIImageView!
    @IBOutlet weak var outerVu: UIView!
    @IBOutlet weak var lbl: UILabel!
    
}


class DashBoardVC: BaseClass, LinkDeleted, LinkAdded, SegmentChanged {
    
    @IBOutlet weak var noLinksAddedByUser: UILabel!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var frontVu: UIView!
    @IBOutlet weak var collectionVu: UICollectionView!

    @IBOutlet weak var coverVu: UIImageView!
    
    @IBOutlet weak var profilepicview: UIView!
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var isSwitchOn =  true
    
    var linksDict = [String:AnyObject]()
    var index = -1
    var userDetails : User?
    var headerIndex : IndexPath? = nil
    var customLinkImgchanged = false
    let storage = Storage.storage()
    
    lazy var emptyStateMessage: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 17)
        messageLabel.sizeToFit()
        return messageLabel
    }()
    var profilePicture = UIImage(named: "ic_image_placeholder")
    var coverPicture = UIImage(named: "ic_image_placeholder")
    var isLeadModeOn =  false

    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
     
//        self.checkLocationService()
//        let storyBoard = UIStoryboard(name: "MapVC", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "AppleMapVC") as! AppleMapVC
//        self.navigationController?.pushViewController(vc, animated: true)
   
        //MARK: Read receipt and update values on firebase
        if iapProducts.count > 0 {
            self.receiptValidation()
        }
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        collectionVu.delegate = self
        collectionVu.dataSource = self
        
        collectionVu.isUserInteractionEnabled = true
        collectionVu.dragInteractionEnabled = true
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionVu.addGestureRecognizer(longPressGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
       
        hidelayout()
        let user = readUserData()
        getUserLinks(id: user?.id)
    }
    
    
    
    func didChangeSegment(segment: UISegmentedControl) {
        
        var dict = ["profileOn":0,
                    "id": getUserId()] as [String : Any]
        
        switch segment.selectedSegmentIndex
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
        
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionVu.indexPathForItem(at: gesture.location(in: collectionVu)) else {
                break
            }
            collectionVu.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionVu.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionVu.endInteractiveMovement()
        default:
            collectionVu.cancelInteractiveMovement()
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addLink" {
            let vc = segue.destination as? InsertLinkVC
            
            let x = userLinks?[index].name?.capitalized
            vc?.platform = x ?? "No Name"
            vc?.text = userLinks?[index].value ?? ""
            vc?.img = userLinks?[index].image ?? ""
            vc?.selectedLink = userLinks?[index]
            vc?.deleteDelegate = self
            vc?.delegate = self
        }
        
        // hides BottomBar Tab using segue line code when open next VC
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    //MARK: Switch Actions
    @objc func leadCaptureSwitchBtn(_ sender: UISwitch) {
        
        guard purchasedSubscription == .lifeTime else {
            sender.isOn.toggle()
            self.showInAppPurchaseAlert()
            return
        }
        
        if (sender.isOn){
            isLeadModeOn = true
        } else{
            isLeadModeOn = false
        }
        APIManager.updateUserLeadMode(userId: self.getUserId(),leadMode: sender.isOn) { status in
            DispatchQueue.main.async {
                if status == true {
                    self.collectionVu.reloadData()
                    print("Lead mode is now updated \(sender.isOn)")
                }
                else {
                    print("Lead mode updating error")
                }
            }
        }
    }
    
    @objc func profileOnOff_toggleBtn(_ sender: UISwitch) {
        didChangeProfileOnOff(isProfileOn: sender.isOn)
    }
    func didChangeProfileOnOff(isProfileOn: Bool) {
        
        var dict = ["profileOn":0,
                    "id": getUserId()] as [String : Any]
        
        switch isProfileOn
        {
        case false:
            dict["profileOn"] = 0
            APIManager.updateUserProfile(dict) { success in
                if success {
                    self.userDetails?.profileOn = 0
                    self.saveUserToDefaults(self.userDetails!)
                    let storyboard = UIStoryboard(name: "ProfileStatusAlert", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "profileStatusAlert_id") as! ProfileStatusAlertVC
                    vc.tag_on_Off_status = false
                    self.present(vc, animated: true, completion: nil)
                }
            }
        case true:
            dict["profileOn"] = 1
            APIManager.updateUserProfile(dict) { success in
                if success {
                    self.userDetails?.profileOn = 1
                    self.saveUserToDefaults(self.userDetails!)
                    
                    let storyboard = UIStoryboard(name: "ProfileStatusAlert", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "profileStatusAlert_id") as! ProfileStatusAlertVC
                    vc.tag_on_Off_status = true
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    //MARK: Button Actions

    @IBAction func leadInfoBtn(_ sender: UIButton) {
        if (isLeadModeOn){
            self.showAlert(title: AlertConstants.Alert, message: "The lead capture is on")
        } else{
            self.showAlert(title: AlertConstants.Alert, message: "The lead capture is off")
        }
    }
    
    @IBAction func profileOnOffInfoBtn(_ sender: UIButton) {
        if (isLeadModeOn){
            self.showAlert(title: AlertConstants.Alert, message: "Your profile is active and visible to others")
        } else{
            self.showAlert(title: AlertConstants.Alert, message: "Your profile is active but not visible to others")
        }
    }
    //MARK: Delegate Methods
    func deleteLink(platform: String) {
        
        startLoading()
        userLinks?.remove(at: index)
        
        APIManager.updateUserLinks() { [self] (success) in
            
            if success {
                let path = IndexPath(item: index, section: 0)
                collectionVu.deleteItems(at: [path])
                stopLoading()
                self.showAlert(title: AlertConstants.Success, message: "Your social icon is successfully removed.")
            } else {
                stopLoading()
                self.showAlert(title: AlertConstants.Error, message: "Social Link could not be deleted.")
            }
        }
        
        if userLinks?.count == 0 || userLinks == nil {
            noLinksAddedByUser.isHidden = false
        }
        
    }
    
    func linkReceived(text: String, platform: String, imageUrl: String?, isShared:Bool) {
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        userLinks?[index].value = text
        userLinks?[index].isShared = isShared
        if !platform.isEmpty {
            userLinks?[index].name = platform
        }
        if let imageUrl = imageUrl, imageUrl != "" {
            if userLinks?[index].linkID == 4 || userLinks?[index].linkID == 22 || userLinks?[index].linkID == 23 || userLinks?[index].linkID == 24 || userLinks?[index].linkID == 25{
                
                userLinks?[index].name = platform
                userLinks?[index].image = imageUrl
                
                self.collectionVu.reloadData()
            }
        }
        APIManager.updateUserLinks() { [self] (success) in
            self.stopLoading()
            if !success {
                //collectionVu.reloadData()
                self.showAlert(title: AlertConstants.Error, message: "User Link Could not be saved, please try again.")
                return
            }
        }
        self.collectionVu.reloadData()
    }
    
    func showlayout() {
        self.frontVu.isHidden = true
        collectionVu.isHidden = false
    }
    
    func hidelayout() {
        self.frontVu.isHidden = false
        collectionVu.isHidden = true
    }
    
    //MARK: User details from firebase
    func getUserLinks(id : String!) {
        
        startLoading()
        
        APIManager.getUserData(id: id) { [self] (data) in
            
            guard data != nil else {
                showAlert(title: AlertConstants.Error, message: "User data not found, Please sign in again.")
                return
            }
            
            userDetails = data
//            if let nsme = userDetails?.profileName, !nsme.isEmpty {self.profileNameLbl.text = nsme} else {self.profileNameLbl.text = "Profile"}
            
            saveUserToDefaults(userDetails!)
            
            userLinks = userDetails?.links
            
            if let url = userDetails?.profileUrl, url != "" {
                downloadImage(from: url)
            }
            
            if let coverUrl = userDetails?.coverUrl, coverUrl != "" {
                    downloadCoverImage(from: coverUrl)
                }
            
            //let addNew = Links.init(value: "Add New", image: "add new.png", name: "Add New")
            //userLinks?.append(addNew)
            
//            if userLinks?.count == 0 || userLinks == nil {
//                userLinks = []
//                //userLinks?.append(addNew)
////                noLinksAddedByUser.isHidden = false
//            } else {
//                self.hideEmptyState()
//            }
            
            self.saveCustomLinkImages()
            
            //TODO: Update Firebase token if it's changed
            if userDetails?.fcmToken != self.getFCM() {
                APIManager.updateUserProfile(
                    ["id": userDetails?.id! as Any,
                     "fcmToken": self.getFCM()
                    ]
                ) { [self] status in
                    if status {
                        self.saveUserToDefaults(userDetails!)
                    }
                }
            }
            
            if let leadMode = userDetails?.leadMode {
                self.isLeadModeOn = leadMode
            }

            self.receiptValidation()
            if let subscrition = userDetails?.subscription {
                switch subscrition {
                case "none":
                    purchasedSubscription = .none
                case "monthly":
                    purchasedSubscription = .monthly
                case "yearly":
                    purchasedSubscription = .yearly
                case "lifeTime":
                    purchasedSubscription = .lifeTime
                default:
                    purchasedSubscription = .none
                }
            }

            if let purchaseDate = userDetails?.subscriptionPurchaseDate {
                subscriptionPurchaseDate = purchaseDate
            }
            if let expiryDateStr = userDetails?.subscriptionExpiryDate {
                subscriptionExpiryDate = expiryDateStr
                
                if let expiryDate = expiryDateFromString(dateString: expiryDateStr), expiryDate < Date() {
                    self.showAlert(title: AlertConstants.Alert, message: "Your app subscription is expired. Please renew your subscription")
                    purchasedSubscription = .none
                    APIManager.updateUserSubscription(subscriptionType: purchasedSubscription) { status in
                        print("\(status)")
                    }
                }
            }
            print(userLinks as Any)
            DispatchQueue.main.async {
                self.showlayout()
                self.stopLoading()
                self.collectionVu.reloadData()
            }
        } error: { [self] err in
            stopLoading()
            showAlert(title: AlertConstants.Error, message: err)
        }
    }
    //coverimage
    
 
    
    //MARK: Save Custom Link Images
    private func saveCustomLinkImages() {
        userDetails?.links?.forEach({ link in
            
            if link.linkID == 4 || link.linkID == 22 || link.linkID == 23 || link.linkID == 24 || link.linkID == 25 {
                self.saveCustomLinkImage(linkImage: link.image, linkId: link.linkID)
            }
        })
    }
    //MARK: Save image from firebase to document directory
    private func saveCustomLinkImage(link: Links) {
        
        if let linkImg = link.image, linkImg != ""  {
            
            let storageRef = Storage.storage().reference(forURL: linkImg)
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
    func downloadCoverImage(from url: String){
        let ref = storage.reference(forURL: url)
        
        DispatchQueue.main.async() { [weak self] in
            
            let header = self?.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self?.headerIndex)!) as? CollectionHeaderView
            
            if let cacheImg = imgChache.object(forKey: ref) as? UIImage {
                header?.coverVu.image = cacheImg
                self?.coverPicture = cacheImg
            } else {
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            imgChache.setObject(img, forKey: ref)
                            header?.coverVu.image = img
                            self?.coverPicture = img
                        }
                    }
                }
                
            }
            
        }
    }
    func downloadImage(from url: String) {
        
        let ref = storage.reference(forURL: url)
        
        DispatchQueue.main.async() { [weak self] in
            
            let header = self?.collectionVu.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader, at: (self?.headerIndex)!) as? CollectionHeaderView
            
            if let cacheImg = imgChache.object(forKey: ref) as? UIImage {
                header?.imgVu.image = cacheImg
                self?.profilePicture = cacheImg
            } else {
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                        // Uh-oh, an error occurred!
                    } else {
                        if let img = UIImage(data: data!) {
                            imgChache.setObject(img, forKey: ref)
                            header?.imgVu.image = img
                            self?.profilePicture = img
                        }
                    }
                }
            }
        }
    }
}
extension DashBoardVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    //        if indexPath.item == values.count {
    //            return false
    //        }
    //        return true
    //    }
    
    //    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //        print("Starting Index: \(sourceIndexPath.item)")
    //        print("Ending Index: \(destinationIndexPath.item)")
    //
    //        let key = imgsArr[sourceIndexPath.item]
    //        let value = values[sourceIndexPath.item]
    //
    //        imgsArr.remove(at: sourceIndexPath.item)
    //        values.remove(at: sourceIndexPath.item)
    //
    //        imgsArr.insert(key, at: destinationIndexPath.item)
    //        values.insert(value, at: destinationIndexPath.item)
    //
    //    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == userLinks?.count {
            return false
        }
        //return self.isSwitchOn == true ? true : false
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
        
        let item = userLinks?[sourceIndexPath.item]
        userLinks?.remove(at: sourceIndexPath.item)
        
        userLinks?.insert(item!, at: destinationIndexPath.item)
        
        /*
         update userlinks to firebase
         */
        
        APIManager.updateUserLinks() { [self] (success) in
            self.stopLoading()
            if !success {
                return
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        
        cell.lbl.text = ""
        cell.imgVu.image = nil
        
        let link = userLinks?[indexPath.row]
        cell.lbl.text = link?.name!
        
        cell.imgVu.image = UIImage(named: link?.name?.lowercased() ?? "")
        cell.imgVu.borderWidthV = 0
        if let link = link, let linkValue = link.value, link.image != nil, linkValue != "", (link.linkID == 4 || link.linkID == 22 || link.linkID == 23 || link.linkID == 24 || link.linkID == 25)  {
            
            cell.imgVu.layer.cornerRadius = 10
            cell.imgVu.layer.masksToBounds = true
        }

        if link?.linkID == 4 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogoImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderColorV = UIColor.black
                    cell.imgVu.borderWidthV = 1
                } else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                }
            } else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0

            }
        } else if link?.linkID == 22 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo2ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderColorV = UIColor.black
                    cell.imgVu.borderWidthV = 1
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                }
            }else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
            }
    }
        
        if link?.linkID == 23 {
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
               if let img = UIImage(contentsOfFile: self.customLogo3ImgUrl.path) {
                   cell.imgVu.contentMode = .scaleToFill
                   cell.imgVu.image = img
                   cell.imgVu.borderColorV = UIColor.black
                   cell.imgVu.borderWidthV = 1
               }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                }
            }  else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
            }
        }
        if link?.linkID == 24 {
            
            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo4ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderColorV = UIColor.black
                    cell.imgVu.borderWidthV = 1
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                }
            } else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
            }
    }
        if link?.linkID == 25 {

            if (link?.value ?? "") != "", (link?.image ?? "") != "" {
                if let img = UIImage(contentsOfFile: self.customLogo5ImgUrl.path) {
                    cell.imgVu.contentMode = .scaleToFill
                    cell.imgVu.image = img
                    cell.imgVu.borderColorV = UIColor.black
                    cell.imgVu.borderWidthV = 1
                }
                else {
                    cell.imgVu.image = UIImage(named: "custom link 5")
                    cell.imgVu.borderWidthV = 0
                }
            } else {
                cell.imgVu.image = UIImage(named: "custom link 5")
                cell.imgVu.borderWidthV = 0
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds
        let width = (size.width / 4) - 30
        let height = width + 25
        return CGSize(width: width, height: height) // viewcollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 22, bottom: 0, right: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //return CGSize(width: collectionView.frame.size.width, height: CGFloat(280.0))
        return CGSize(width: collectionView.frame.size.width, height: 450.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        index = indexPath.row
        performSegue(withIdentifier: "addLink", sender: self)
    }
    
    func showEmptyState(message: String) {
        emptyStateMessage.text = message
        collectionVu.addSubview(emptyStateMessage)
        emptyStateMessage.centerXAnchor.constraint(equalTo: collectionVu.centerXAnchor).isActive = true
        emptyStateMessage.centerYAnchor.constraint(equalTo: collectionVu.centerYAnchor,constant: 50).isActive = true
    }
    
    func hideEmptyState() {
        emptyStateMessage.removeFromSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = userLinks?.count ?? 0
        
        return rows
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: Collectionview Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderView", for: indexPath) as? CollectionHeaderView else {
                fatalError("Invalid view type")
            }
        
        headerView.delegate = self
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            headerView.nameLbl.text = userDetails?.name ?? ""
            headerView.userNameLbl.text = userDetails?.username ?? ""
            headerView.emailLbl.text = userDetails?.email ?? ""
            headerView.phoneLbl.text = userDetails?.phone ?? ""
            headerView.companyLbl.text = userDetails?.company ?? ""
            
            headerView.imgVu.image = profilePicture
            headerView.coverVu.image = coverPicture
            headerIndex = indexPath
            let numberOfPostsViewSelector : Selector = #selector(self.didSelectHeader)
            let viewPostsViewGesture = UITapGestureRecognizer(target: self, action: numberOfPostsViewSelector)
            viewPostsViewGesture.numberOfTapsRequired = 1
            viewPostsViewGesture.delaysTouchesBegan = true
            headerView.containerView.addGestureRecognizer(viewPostsViewGesture)
            
            headerView.leadCapture_toggleBtn.isOn = isLeadModeOn
            headerView.leadCapture_toggleBtn.addTarget(self, action: #selector(leadCaptureSwitchBtn(_:)), for: .valueChanged)
            
            if userDetails?.profileOn == 1 {
                headerView.profileOnOff_toggleBtn.isOn = true
            } else {
                headerView.profileOnOff_toggleBtn.isOn = false
            }
            headerView.profileOnOff_toggleBtn.addTarget(self, action: #selector(profileOnOff_toggleBtn(_:)), for: .valueChanged)
            //profileOnOff_toggleBtn
            
        default:
            assert(false, "Invalid element type")
        }
        
        // editUserBtn
        headerView.editUserBtn.tag = indexPath.row
        headerView.editUserBtn.addTarget(self, action: #selector(self.editUserBtnObserver(_:)), for: .touchUpInside)
        
        return headerView
    }
    
    // editUserBtnObserver observer
    @objc func editUserBtnObserver(_ sender: UIButton)
    {
        NotificationCenter.default.post(name: Notification.Name("changeRootVC"), object: nil, userInfo: ["VCName":"AddLinksVC"])
    }
    
    
    @objc func didSelectHeader(sender: UITapGestureRecognizer){
        print("HErE")
        NotificationCenter.default.post(name: Notification.Name("changeRootVC"), object: nil, userInfo: ["VCName":"AddLinksVC"])
    }
    
    
    func setBoarder(id:Int) -> Bool{
        if id == 4 || id == 22 || id == 23 || id == 24 || id == 25 {
            return true
        }else{
            return false
        }
    }
}

extension DashBoardVC {
    //MARK: Save custom link images
    private func saveCustomLinkImage(linkImage: String?, linkId: Int?) {
        // Custom link Image 1
        guard let linkImage = linkImage, linkImage != "", linkImage.lowercased() != "custom link",linkImage.lowercased() != "custom link 2",linkImage.lowercased() != "custom link 3", linkImage.lowercased() != "pdf", linkImage.lowercased() != "sales brochure" else {
            return
        }
        let storageRef = storage.reference(forURL: linkImage)
        DispatchQueue.main.async() {
            storageRef.getData(maxSize: 1 * 1024 * 8024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    // Uh-oh, an error occurred!
                } else {
                    if let img = UIImage(data: data!) {
                        self.saveInDocumentDirectory(linkId: linkId, img: img)
                        self.collectionVu.reloadData()
                    }
                }
            }
        }
    }
    
    func saveInDocumentDirectory(linkId:Int?, img: UIImage) {
        if linkId == 4 {
            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogoImgUrl)
        } else if linkId == 22 {
            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo2ImgUrl)
        } else if linkId == 23 {
            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo3ImgUrl)
        } else if linkId == 24 {
            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo4ImgUrl)
        } else if linkId == 25 {
            self.saveLogoImageInDocumentDirectory(image: img, url: self.customLogo5ImgUrl)
        }
    }
}

