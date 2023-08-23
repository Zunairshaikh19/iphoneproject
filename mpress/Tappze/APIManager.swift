

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase
import Alamofire

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    typealias ErrorType = (String) -> Void
    typealias StringType = (String)-> Void
    typealias BoolType = (Bool) -> Void
    typealias DictionaryType = ([String:String])-> Void
    typealias dictionaryParameter = [String:Any]
    
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    static func isInternetAvailable() -> Bool {
        guard APIManager.shared.reachabilityManager?.isReachable == true else {return false}
        return true
    }
    
    static func getBaseUrl(completion: @escaping (_ baseURL: String?)-> Void,
                           err: @escaping ErrorType) {
        
        Constants.refs.databaseBaseUrl.observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists() {
                print("-----------snapshot exists--------")
                
                if let response = snapshot.value as? [String:String] {
                    print(response)
                    _ = snapshot.key
                    let url = response["url"]!
                    completion(url)
                }
            } else {
                print("doesn't exist")
                completion("")
                
            }
        }
    }
    
    static func tagVerification(_ id: String, completion: @escaping (_ response: Dictionary<String, AnyObject>) -> Void){
        
        Constants.refs.databaseTag.queryOrdered(byChild: "tagId").queryEqual(toValue: id).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists() {
                if let tagData = snapshot.value as? Dictionary<String, AnyObject> {
                    completion(tagData)
                }
            }
        }
    }
    
    static func tagStatusUpdate(_ id: String, _ username: String, completion: @escaping (_ status: Bool) -> Void){
        
        
        Constants.refs.databaseTag.child(id).updateChildValues([
            "status":true,
            "username":username
        ]) { (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("Tag status could not be updated: \(error).")
                completion(false)
            } else {
                print("Tag status successfully update.")
                completion(true)
            }
        }
    }
    
    
    static func signUp(params: dictionaryParameter,password: String,
                       completion: @escaping (_ isAlreadyExist: Bool,_ userId: String,_ err: String  )-> Void,
                       returnedError: @escaping ErrorType) {
        
        var param = params
        Constants.refs.databaseUser.queryOrdered(byChild:"username").queryEqual(toValue: param["username"]).observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.exists()) {
                completion(false, "", "User name already exists.")
            } else {
                print("Username is available")
                Auth.auth().createUser(withEmail: param["email"] as! String, password: password) { authResult, error in
                    if error == nil {
                        //let fcm = UserDefaults.standard.value(forKey: "FCMToken") as? String ?? ""
                        print(authResult?.user as Any)
                        
                        let user = User(id: authResult?.user.uid, name: param["name"] as? String, email: param["email"] as? String, fcmToken: BaseClass().getFCM(), profileUrl: "", bio: "", username: param["username"] as? String, phone: "", gender: "", dob: "", address: "", parentID: authResult?.user.uid, profileOn: 1, isDeleted: false, platform: "iOS", profileName: "")
                        
                        param.removeAll()
                        param = user.asDictionary
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: Constants.customer)
                        UserDefaults.standard.synchronize()
                        
                        // Create User on firebase
                        Constants.refs.databaseUser.child((authResult?.user.uid)!).setValue(param) { (error:Error?, ref:DatabaseReference) in
                            
                            if let error = error {
                                print("Data could not be saved: \(error).")
                                completion(false,"", error.localizedDescription)
                            } else {
                                print("Data updated successfully!")
                                completion(true, (authResult?.user.uid)!,"")
                            }
                        }
                        
                        
                    } else {
                        returnedError(error?.localizedDescription ?? AlertConstants.SomeThingWrong)
                    }
                }
                
            }
        }) { (error) in
            returnedError(error.localizedDescription )
        }
    }
    
    static func downloadImage(from url: URL,completion: @escaping(_ image: UIImage?)-> Void)  {
        //        let img = UIImage(named: "img")
        print("Download Started")
        BaseClass().getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            completion((UIImage(data: data)))
        }
    }
    static func updateUserProfile(_ dict: dictionaryParameter, completion: @escaping(_ status: Bool)-> Void) {
        
        let id = dict["id"] as! String
        
        Constants.refs.databaseUser.child(id).updateChildValues(dict) { (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false)
            } else {
                print("Data updated successfully!")
                completion(true)
            }
        }
    }
    
    static func updateConnectUserValue(contactId: String,_ dict: dictionaryParameter, completion: @escaping(_ status: Bool)-> Void) {
        
        //        let userId = BaseClass().getUserId()
        Constants.refs.databaseContacts.updateChildValues(dict) { (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false)
            } else {
                print("Data updated successfully!")
                completion(true)
            }
        }
    }
    
    static func updateUserLinks(completion: @escaping(_ status: Bool)-> Void) {
        
        var customer: User?
        var dict = [String: Any]()
        var links = userLinks
        
        if let addIndex = links?.firstIndex(where: {$0.name == "Add New"}) {
            links?.remove(at: addIndex)
        }
        
        for i in 0..<(links ?? []).count {
            dict["\(i)"] = links?[i].asDictionary
        }
        
        print(dict,"Latest Dict of links")
        
        
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
            print(customer!)
        }
        
        
        
        Constants.refs.databaseUser.child((customer?.id)!).child("links").setValue(dict) { (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("User Links could not be saved: \(error).")
                completion(false)
            } else {
                print("User Links updated successfully!")
                completion(true)
            }
        }
    }
    //isCardPurchased
    //subscription
    //subscriptionExpiryDate
    //subscriptionPurchaseDate
    
    //isProVersion
    //isSubscribed

    //MARK: IN-App Purchase on firebase
    static func updateUserCardStatus(cardStatus: Bool?, completion: @escaping(_ status: Bool)-> Void) {
        var customer: User?
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
            print(customer!)
        }
        Constants.refs.databaseUser.child((customer?.id)!).child("isCardPurchased").setValue(cardStatus) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User card status could not be saved: \(error).")
                completion(false)
            } else {
                print("Card status updated successfully!")
                completion(true)
            }
        }
    }
    
    static func updateUserSubscription(subscriptionType: Subscription?, completion: @escaping(_ status: Bool)-> Void) {
        
        var customer: User?
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
            print(customer!)
        }
        // Saving isProVersion and isSubscribed For android app
        if subscriptionType! == .none {
            Constants.refs.databaseUser.child((customer?.id)!).child("isProVersion").setValue(false)
            Constants.refs.databaseUser.child((customer?.id)!).child("isSubscribed").setValue(false)
        }
        else if subscriptionType! == .monthly ||  subscriptionType! == .yearly || subscriptionType! == .lifeTime {
            Constants.refs.databaseUser.child((customer?.id)!).child("isProVersion").setValue(true)
            Constants.refs.databaseUser.child((customer?.id)!).child("isSubscribed").setValue(true)
        }

        Constants.refs.databaseUser.child((customer?.id)!).child("subscription").setValue(subscriptionType?.rawValue) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User subscription could not be saved: \(error).")
                completion(false)
            } else {
                print("Subscription updated successfully!")
                completion(true)
            }
        }
    }
    
    //MARK: Update pro version purchase date
    static func updateSubscriptionPurchaseDate(purchaseDate: String?, completion: @escaping(_ status: Bool)-> Void) {
        var customer: User?
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
            print(customer!)
        }
        Constants.refs.databaseUser.child((customer?.id)!).child("subscriptionPurchaseDate").setValue(purchaseDate) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User Pro version purchase date could not be saved: \(error).")
                completion(false)
            } else {
                print("Pro version purchase date updated successfully!")
                completion(true)
            }
        }
    }
    
    //MARK: Update pro version expiry date
    static func updateSubscriptionExpiryDate(expiryDate: String?, completion: @escaping(_ status: Bool)-> Void) {
        var customer: User?
        if let data = UserDefaults.standard.value(forKey:Constants.customer) as? Data {
            customer = try! PropertyListDecoder().decode(User.self, from: data)
            print(customer!)
        }
        Constants.refs.databaseUser.child((customer?.id)!).child("subscriptionExpiryDate").setValue(expiryDate) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User subscription Expiry date could not be saved: \(error).")
                completion(false)
            } else {
                print("subscription Expiry date updated successfully!")
                completion(true)
            }
        }
    }
    static func deleteLinkFromFirebase(ref: DatabaseReference,
                                       completion: @escaping(_ status:Bool)-> Void,
                                       err: @escaping ErrorType) {
        
        ref.removeValue { (error, ref) in
            
            if error != nil {
                err(error!.localizedDescription)
            } else {
                completion(true)
            }
        }
    }
    
    
    static func addNewContactToFirebase(myId: String,_ dict: dictionaryParameter, completion: @escaping(_ status: Bool,_ msg:String) -> Void) {
        
        let contactId = dict["id"] as! String
        print(contactId)
        Constants.refs.databaseContacts.child(myId).child(contactId).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                completion(false, "This user is already added to your contacts.")
            } else {
                Constants.refs.databaseContacts.child(myId)
                    .child(contactId).setValue(dict) { (error:Error?, ref:DatabaseReference) in
                        
                        if let error = error {
                            print("Data could not be saved: \(error).")
                            completion(false, error.localizedDescription)
                        } else {
                            print("Data updated successfully!")
                            completion(true, "Success")
                        }
                    }
                
            }
        }
    }
    
    static func getUserLinksForDashboard(id: String,
                                         completion: @escaping (_ user: [Links]?)-> Void,
                                         error: @escaping ErrorType) {
        print("User ID: ",id)
        var arr = [Links]()
        Constants.refs.databaseUser.child(id).child("links").observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                print("-----------exists--------")
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        if let userLinks = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            print(key)
                            
                            do {
                                let links = try FirebaseDecoder().decode(Links.self, from: userLinks)
                                if links.value != "" {
                                    arr.append(links)
                                }
                                
                            } catch let error {
                                print(error)
                                
                            }
                        }
                    }
                    completion(arr)
                }
            } else {
                print("doesn't exist")
                completion(nil)
            }
        }
    }
    static func getAllLinks(completion: @escaping (_ user: [Links]?)-> Void,
                            error: @escaping ErrorType) {
        var arr = [Links]()
        Constants.refs.allLinks.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                print("-----------exists--------")
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        if let userLinks = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            print(key)
                            
                            do {
                                let user = try FirebaseDecoder().decode(Links.self, from: userLinks)
                                print(user)
                                
                                arr.append(user)
                                
                            } catch let error {
                                print(error)
                                
                            }
                        }
                    }
                    completion(arr)
                }
            } else {
                print("doesn't exist")
                completion(nil)
            }
        }
    }
    
    static func getUserData(id: String,
                            completion: @escaping (_ user: User?)-> Void,
                            error: @escaping ErrorType) {
        print("User ID:",id)
        let uid = id.trimmingCharacters(in: .whitespaces)
        
        Constants.refs.databaseUser.child(uid).observeSingleEvent(of: .value) { (snap, error) in
            
            print(snap)
            if snap.exists() {
                print("-----------User Data exists--------")
                
                if let userData = snap.value as? Dictionary<String, AnyObject> {
                    let key = snap.key
                    print(key)
                    
                    do {
                        let user = try FirebaseDecoder().decode(User.self, from: userData)
                        print(user)
                        completion(user)
                    } catch let error {
                        print(error)
                        completion(nil)
                    }
                }
            } else {
                print("doesn't exist")
                print(snap)
                completion(nil)
            }
        }
    }
    
    static func getAllUsers(id: String, parentId: String, completion: @escaping (_ user: [User]?)-> Void,
                            error: @escaping ErrorType) {
        var arr = [User]()
        
        Constants.refs.databaseUser.queryOrdered(byChild: "parentID").queryEqual(toValue: parentId).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                print("-----------exists--------")
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        if let users = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            print(key)
                            
                            do {
                                let user = try FirebaseDecoder().decode(User.self, from: users)
                                print(user)
                                
                                arr.append(user)
                                
                            } catch let error {
                                print(error)
                                
                            }
                        }
                    }
                    completion(arr)
                }
            } else {
                print("doesn't exist")
                completion(nil)
            }
        }
    }
    
    static func getContactsList(id: String,
                                completion: @escaping (_ user: [User]?)-> Void,
                                error: @escaping ErrorType) {
        print("User ID:",id)
        var arr = [User]()
        
        Constants.refs.databaseContacts.child(id).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                
                guard let value = snapshot.value else { return }
                if let snapshot = value as? Dictionary<String, AnyObject> {
                    
                    for snap in snapshot {
                        if let userData = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            print(key)
                            
                            do {
                                let user = try FirebaseDecoder().decode(User.self, from: userData)
                                print(user)
                                
                                arr.append(user)
                                
                            } catch let error {
                                print(error)
                                
                            }
                        }
                    }
                    completion(arr)
                }
            } else {
                completion(nil)
            }
        })
    }
    
    //MARK: Update LeadMode

    static func updateUserLeadMode(userId: String, leadMode: Bool, completion: @escaping(_ status: Bool)-> Void) {
        let refrence = Constants.refs.databaseUser.child(userId)
        //old: EkqSL7WBwHSpe9WgYIWhocH1rjv2
        refrence.child("leadMode").setValue(leadMode) { (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("User Links could not be saved: \(error).")
                completion(false)
            } else {
                print("User Links updated successfully!")
                completion(true)
            }
        }
    }
    //MARK: getAnalytics
    static func getAnalytics(_ userid: String, completion: @escaping(_ analytics: Analytic?) -> Void) {
        
        Constants.refs.databaseAnalytic.queryOrdered(byChild: "userid").queryEqual(toValue: userid).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists() {
                
                guard let value = snapshot.value else { return }
                if let snapshot = value as? Dictionary<String, AnyObject> {
                    
                    for snap in snapshot {
                        if let data = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            print(key)
                            
                            do {
                                let analytics = try FirebaseDecoder().decode(Analytic.self, from: data)
                                print(analytics)
                                completion(analytics)
                            } catch let error {
                                print(error)
                                completion(nil)
                            }
                        }
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
}

