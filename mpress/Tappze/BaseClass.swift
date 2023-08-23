

import Foundation
import UIKit
import CropViewController
import NVActivityIndicatorView
import Network
import MessageUI
import AnimatedField
import Firebase
import FirebaseStorage
import CoreLocation

class BaseClass: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CropViewControllerDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {
    
#if DEBUG
let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
#endif
    let locationManager = CLLocationManager()
    var location : String = ""
    
    var loaderIndicator: NVActivityIndicatorView? = nil
    var imagePicker = UIImagePickerController()
    var customer: User?
    
    var customLogoImg: UIImage?
    var customLogoImg2: UIImage?
    var customLogoImg3: UIImage?
    var customLogoImg4: UIImage?
    var customLogoImg5: UIImage?

    func getLinkImgLocalPath(linkID: String) -> URL{
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("\(linkID).png")
    }
    
    var customLogoImgUrl: URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documents.appendingPathComponent("customLogoImg.png")
        }
        var customLogo2ImgUrl: URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documents.appendingPathComponent("customLogoImg2.png")
        }
        var customLogo3ImgUrl: URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documents.appendingPathComponent("customLogoImg3.png")
        }
        var customLogo4ImgUrl: URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documents.appendingPathComponent("customLogoImg4.png")
        }
    var customLogo5ImgUrl: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("customLogoImg5.png")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderinit()
        //        whiteLoaderinit()
    }
    
    @available(iOS 12.0, *)
    func isNetworkAvailable() -> Bool {
        var internet = false
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.usesInterfaceType(.cellular) {
                    print("celullar")
                } else if path.usesInterfaceType(.wifi) {
                    print("It's WiFi!")
                }
                DispatchQueue.main.async {
                    
                    print("There is internet")
                }
                internet = true
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: AlertConstants.InternetNotReachable,message: "")
                    print("There is no internet")
                    //                    self.backgroundVu.isHidden = false
                    //                    self.noNet.isHidden = false
                    //                    self.retryBtn.isHidden = false
                    //                    self.activityIndicator.isHidden = true
                }
                internet = false
                
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        return internet
    }
    
    func saveUserToDefaults(_ value: User) {
        
        let dict: User = User(id: value.id, name: value.name, email: value.email, fcmToken: value.fcmToken, profileUrl: value.profileUrl, coverUrl: value.coverUrl, bio: value.bio, username: value.username, phone: value.phone, gender: value.gender, dob: value.dob, address: value.address, parentID: value.parentID, profileOn: value.profileOn, isDeleted: value.isDeleted, company: value.company, isCardPurchased: value.isCardPurchased, subscription: value.subscription, subscriptionExpiryDate: value.subscriptionExpiryDate, subscriptionPurchaseDate: value.subscriptionPurchaseDate,leadMode: value.leadMode, profileName: value.profileName,infoShareable: value.infoShareable)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(dict), forKey: Constants.customer)
        
        UserDefaults.standard.setValue(true, forKey: Constants.status)
        UserDefaults.standard.synchronize()
    }
    
    
    
    func readUserData() -> User? {
        
        var customer: User?
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
        }
        
        return customer
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getProfileUrl() -> String {
        
        let user = readUserData()
        return user?.profileUrl ?? ""
    }
    func getCoverUrl() -> String {
        
        let user = readUserData()
        return user?.coverUrl ?? ""
    }
    func saveFCM (_ fcm: String) {
        UserDefaults.standard.setValue(fcm, forKey: "FCMToken")
        UserDefaults.standard.synchronize()
    }
    
    func getFCM() -> String {
        return UserDefaults.standard.value(forKey: "FCMToken") as? String ?? ""
    }
    
    func getUsername() -> String {
        
        let user = readUserData()
        return user?.username ?? ""
    }
    
    func getName() -> String {
        let user = readUserData()
        return user?.name ?? ""
    }
    
    func showPermissionAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func getBio() -> String {
        let user = readUserData()
        return user?.bio ?? "Bio"
    }
    
    func getUserId() -> String {
        let user = readUserData()
        return user?.id ?? ""
    }
    
    func getEmail() -> String {
        let user = readUserData()
        return user?.email ?? ""
    }
    
    func deleteUserModel() {
        let user = User()
        saveUserToDefaults(user)
        print("user data deleted")
    }
    
    func loaderinit() {
        loaderIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 25, y: self.view.frame.height/2 , width: 50, height: 50), type: .ballScaleRippleMultiple, color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), padding: 1)
        view.addSubview(loaderIndicator!)
    }
    
    func startLoading() {
        loaderIndicator?.startAnimating()
    }
    
    func stopLoading() {
        loaderIndicator?.stopAnimating()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true) {
                self.openImageCropper(image: image)
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func openImageCropper(image: UIImage) {
        
        let cropViewController = CropViewController(image: image)
        cropViewController.toolbar.clampButtonHidden = true
        cropViewController.doneButtonColor = UIColor.white
        cropViewController.cancelButtonColor = UIColor.red
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.delegate = self
        let nvc = UINavigationController(rootViewController: cropViewController)
        present(nvc, animated: true, completion: nil)    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("Image Cropped!")
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, onSuccess closure: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
            closure()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTwoBtnAlert (title: String, message: String,yesBtn:String,noBtn:String, onSuccess success: @escaping (Bool) -> Void) {
        
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: yesBtn, style: .destructive, handler: { (action) -> Void in
            
            print("Yes button click...")
            success(true)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: noBtn, style: .cancel) { (action) -> Void in
            print("Cancel button click...")
            success(false)
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    func addShadowToView(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.5, height: 3.0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
    }
    func addShadowtoBtn(btn: UIButton) {
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize.zero
        btn.layer.shadowRadius = 7.0
        btn.layer.shadowOpacity = 0.5
        btn.layer.masksToBounds = false
    }
    func pushController(controller toPush: String, storyboard: String) {
        let controller = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: toPush)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getControllerRef(controller toPush: String, storyboard: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: toPush)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func sendEmail(_ email: String) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.title = ""
            mail.setToRecipients([email])
            
            mail.setSubject("")
            
            mail.setMessageBody("", isHTML: false)
            
            self.present(mail, animated: true, completion: nil)
            
        } else {
            // show failure alert
            showMailServiceErrorAlert()
            return
        }
    }
    
    func showMailServiceErrorAlert(){
        self.showAlert(title: "Mail services are not available",message: "")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue :
            print("Cancelled")
            
        case MFMailComposeResult.failed.rawValue :
            print("Failed")
            
        case MFMailComposeResult.saved.rawValue :
            print("Saved")
            
        case MFMailComposeResult.sent.rawValue :
            print("Sent")
            
        default: break
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func downloadImage(imgVu: UIImageView, url: String) {
        
        let ref = Storage.storage().reference(forURL: url)
        DispatchQueue.main.async() {
            ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let myImage: UIImage! = UIImage(data: data!)
                    imgVu.image = myImage
                }
            }
        }
    }
    
    //:-
    // textField animated code
    func animated_textField(tfName: AnimatedField)
    {
        tfName.format.lineColor = UIColor.lightGray
        tfName.format.titleColor = UIColor.lightGray
        tfName.format.textColor = UIColor.clrBlack
        tfName.format.highlightColor = UIColor.clrBlack
        // tint color
        tfName.tintColor = UIColor.lightGray
        // counter is hide
        tfName.format.counterEnabled = false
        // for external font used
        tfName.format.textFont = UIFont(name: "Poppins-Regular", size: 15)!
        tfName.format.titleFont = UIFont(name: "Poppins-Regular", size: 16)!
    }
    
    func expiryDateFromString(dateString: String?) -> Date? {
        
        if let dateString = dateString {
            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            formatter.dateFormat = "yyyy-MM-dd"
            let formatedDate = formatter.date(from: dateString)
            return formatedDate
        }
        else {
            return nil
        }
    }
    
    
    //MARK: Save logo image in document directory
    func saveLogoImageInDocumentDirectory(image: UIImage?, url:URL)
    {
        if let data = image?.pngData() {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
    func deleteAllCustomLinkImages() {
        self.deleteLogoImageFromDocumentDirectory(url: customLogoImgUrl)
        self.deleteLogoImageFromDocumentDirectory(url: customLogo2ImgUrl)
        self.deleteLogoImageFromDocumentDirectory(url: customLogo3ImgUrl)
        self.deleteLogoImageFromDocumentDirectory(url: customLogo4ImgUrl)
        self.deleteLogoImageFromDocumentDirectory(url: customLogo5ImgUrl)
    }
    //MARK: Delete logo Image from document directory
    func deleteLogoImageFromDocumentDirectory(url:URL) {
        do {
            try FileManager.default.removeItem(atPath: url.path)
        }
        catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    //MARK: IN-App alerts
    func showInAppPurchaseAlert() {
        self.showTwoBtnAlert(title: "Purchase a subscription plan to use this feature.", message: "Do you want to purchase?", yesBtn: "Yes", noBtn: "No") { buttonPressed in
            if buttonPressed == true {
                self.goToInAppPurchaseVC(previousVC: "dashboard")
            }
            else {
                print("Do nothing")
            }
        }
    }

    func goToInAppPurchaseVC(previousVC: String?) {
        print("Go to purchase screen")
        let storyboard = UIStoryboard(name: "InAppPurchase", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseVC") as! InAppPurchaseVC
        vc.previousVC = previousVC
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    func isValidPhone(phone: String) -> Bool {
            let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: phone)
        }

    func isValidEmail(email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: email)
        }
    func isValidPassword(passwrd: String) -> Bool {
        let passwordRegex = "(?=[^A-Za-z]*[A-Za-z])(?=[^0-9]*[0-9])[A-Za-z0-9]{8,50}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: passwrd)
    }
    
    func isvalidURL(checkUrl: String) -> Bool {
//            let regEx = "((http|https|ftp)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
       let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: checkUrl)
        
    }
}


//MARK: In-App Purchase
extension BaseClass {
    //MARK: IN-APP-Purchase Receipt Work
    // function for get the receiptValidation from the server for get  receiptValiation we need to recieptString and shared secret which will provided by Apple and we have pass those in following way to get All the subscription Data
    func receiptValidation() {
        
        guard let receiptFileURL = Bundle.main.appStoreReceiptURL else { return}
        let receiptData = try? Data(contentsOf: receiptFileURL)
        guard let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) else { return}
        //TODO: secret key to change:
        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString as AnyObject, "password" : "d8950a343013450196a05a502a2585c6" as AnyObject]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    do {
                        guard let data = data else {
                            return
                        }
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                        print("=======>",jsonResponse)
                        if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
                            self?.expiryDateValidations(date: date)

                        }
                    }
                    catch let parseError {
                        print(parseError)
                    }
                }
            })
            task.resume()
        } catch let parseError {
            print(parseError)
        }
    }
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> String? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            print(lastReceipt)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            if let expiresDate = lastReceipt["expires_date"] as? String {
                return expiresDate
            }
            
            if let original_purchase_date = lastReceipt["original_purchase_date"] as? String {
                print(original_purchase_date)
            }
            
            if let expires_date_ms = lastReceipt["expires_date_ms"] as? String {
                print(expires_date_ms)
            }
            
            return nil
            
        } else {

            return nil
        }
    }
    
    func expiryDateValidations(date: String?) {

        if let expDate = self.expiryDateFromString(dateString: date), expDate < Date() {
            
            purchasedSubscription = .none
            var loggedUser = self.readUserData()
            loggedUser?.subscription = purchasedSubscription.rawValue
            self.saveUserToDefaults(loggedUser!)
            APIManager.updateUserSubscription(subscriptionType: purchasedSubscription) { status in
                
                print("\(status)")
            }
            self.showAlert(title: "Alert!", message: "Subscription expired on date: \(String(describing: date))")
        }
        APIManager.updateSubscriptionExpiryDate(expiryDate: date) { status in
            if status == true {
                print("Expiry date updated")
            }
            else {
                print("Expiry date not updated")
            }
        }
    }
    
    //MARK: Open Url
    func openUrlWithString(urlString: String?) {

        let encodedUrl = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: (urlString ?? "")), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        } else if let url = URL(string: (encodedUrl ?? "")), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else  {
            self.showAlert(title: AlertConstants.Alert, message: "Can not open url")
        }
    }
    
    //MARK: Location Work
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                showPermissionAlert()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.startUpdatingLocation()
            @unknown default:
                getLocation()
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    func getLocation(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        //locationManager.showsBackgroundLocationIndicator = true
        //locationManager.allowsBackgroundLocationUpdates = true
        
        //Location
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.distanceFilter = 100
                self.locationManager.requestLocation()
                self.locationManager.startUpdatingLocation()
            } else {
                self.showPermissionAlert()
            }
        }
    }    
    func showPermissionAlert() {
        let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            currentLocation = location
            print("Location data received",location.coordinate)
            locationManager.stopUpdatingLocation()
        }
        
        currentLocation = locations.last
        
        let userLocation :CLLocation = locations.last!
        let currentUserLat = userLocation.coordinate.latitude
        let currentUserLong = userLocation.coordinate.longitude
        print("user latitude = \(currentUserLat)")
        print("user longitude = \(currentUserLong)")
//        let tempLocation = UserLocation(latitude: "\(userLocation.coordinate.latitude)", longitude: "\(userLocation.coordinate.longitude)")
//
//        APIManager.updateLocation(location: tempLocation) { status in
//        }

        self.location = "\(userLocation.coordinate.latitude)" + ",\(userLocation.coordinate.longitude)"
        print(self.location)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location fetch error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        }
    }
}
