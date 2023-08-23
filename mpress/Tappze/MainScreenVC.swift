

import UIKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit
import FirebaseCore
import Firebase
import AudioToolbox
import CryptoKit
import AuthenticationServices

class MainScreenVC: BaseClass {
    
    
    //    MARK: - Private Outlets
    @IBOutlet private weak var createAccountBtn: UIButton!
    @IBOutlet private weak var googleBtn: UIButton!
    @IBOutlet private weak var facebookBtn: UIButton!
    @IBOutlet private weak var appleBtn: UIButton!
    @IBOutlet private weak var loginWithEmail: UIButton!
    @IBOutlet private weak var appleLogo: UIImageView!
    @IBOutlet private weak var googleStackV: UIStackView!
    @IBOutlet private weak var fbStackView: UIStackView!
    @IBOutlet private weak var appleStackView: UIStackView!
    
    
    fileprivate var currentNonce: String?
    var userDetails : User?
    var email = ""
    var name = ""
    var uid = ""
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.addShadowtoBtn(btn: createAccountBtn)
        self.addShadowtoBtn(btn: appleBtn)
        self.addShadowtoBtn(btn: facebookBtn)
        self.addShadowtoBtn(btn: googleBtn)
//        self.addShadowtoBtn(btn: loginWithEmail)
        //        faceBookSetup()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Initial UI Setup
    private func setUpUI() {
        
        //createAccountBtn.clipsToBounds = true
        createAccountBtn.layer.cornerRadius = createAccountBtn.layer.frame.size.height / 2
        googleBtn.layer.cornerRadius = googleBtn.layer.frame.size.height / 2
        facebookBtn.layer.cornerRadius = facebookBtn.layer.frame.size.height / 2
        appleBtn.layer.cornerRadius = appleBtn.layer.frame.size.height / 2
        //googleStackV.clipsToBounds = true
        googleStackV.layer.cornerRadius = 8
        
        //fbStackView.clipsToBounds = true
        fbStackView.layer.cornerRadius = 8
        
        //appleStackView.clipsToBounds = true
        appleStackView.layer.cornerRadius = 8
        appleLogo.image = appleLogo.image!.withRenderingMode(.alwaysTemplate)
        appleLogo.tintColor = .white
        
        //loginWithEmail.clipsToBounds = true
        loginWithEmail.layer.cornerRadius = 8
        loginWithEmail.backgroundColor = .white
        loginWithEmail.borderColorV = .gray
        loginWithEmail.borderWidthV = 0
        
    }
    
    
    //MARK: Signup With Email
    @IBAction func createAccountBtnAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toCreateAccount", sender: nil)
    }
    
    @IBAction func googleBtnAction(_ sender: Any) {
        self.googleSignInAuthentication()
    }
    
    
    private func googleSignInAuthentication() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        startLoading()
        
        // Start the sign in flow!
        
        //GIDSignIn.sharedInstance.signIn(withPresenting: self) { [self] user, err in
        
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [self] user, err in
            
            if let error = err {
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                return
            }
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken
            else {
                self.stopLoading()
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            self.autheticateWithFirebaseGoogle(credential: credential,user: user!)
        }
        
    }
    
    func autheticateWithFirebaseGoogle(credential: AuthCredential, user: GIDGoogleUser) {
        
        Auth.auth().signIn(with: credential) { authResult, error in
            
            if let error = error {
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else {return}
            
            APIManager.getUserData(id: uid) { (userDetails) in
                
                if userDetails != nil { // User data already found on database
                    if userDetails?.isDeleted == true {
                        self.stopLoading()
                        self.showAlert(title: AlertConstants.Alert, message: "Your Account is locked, contact to admin")
                    } else {
                        self.saveUserToDefaults(userDetails!)
                        self.stopLoading()
                        
                        let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                        "toBottomBarID")
                        UIApplication.shared.windows.first?.rootViewController = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                    
                } else { // User data is not found on database
                    
                    let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                    
                    vc.uid = uid
                    vc.email = user.profile?.email ?? ""
                    vc.name = user.profile?.name ?? ""
                    
                    if let url = user.profile?.imageURL(withDimension: 150) {
                        vc.profileImgUrl = "\(url)"
                    }
                    
                    self.stopLoading()
                    vc.isSocialLogin = true
                    
                    self.stopLoading()
                    //                    vc.isSocialLogin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } error: { (desc) in
                self.stopLoading()
                self.showAlert(title: AlertConstants.Error, message: desc)
            }
        }
    }
    
    //MARK: Facebook Login
    //    private func faceBookSetup() {
    //
    //        if let token = AccessToken.current, !token.isExpired {
    //            let  token = token.tokenString
    //
    //            let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
    //                                                     parameters: ["fields": "email, name"],
    //                                                     tokenString: token,
    //                                                     version: nil,
    //                                                     httpMethod: .get)
    //            request.start()
    //
    //        } else {
    //            facebookBtn.delegate = self
    //            facebookBtn.permissions = ["public_profile", "email"]
    //        }
    //    }
    
    @IBAction func facebookBtnAction(_ sender: Any) {
        
        startLoading()
        let manager = LoginManager()
        
        manager.logIn(permissions: [.publicProfile,.email], viewController: self) { [self] (result) in
            switch result {
            case .success(_,_,_):
                let credential = FacebookAuthProvider
                    .credential(withAccessToken: AccessToken.current!.tokenString)
                
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, relationship_status, picture.type(large)"]) .start { (connection, result, error) in
                    if (error == nil)
                    {
                        let fbDetails = result as! NSDictionary
                        print("fbDetails",fbDetails)
                        self.email = fbDetails["email"] as! String
                        self.name = fbDetails["name"] as! String
                        self.uid = fbDetails["id"] as! String
                        //
                        
                        Auth.auth().signIn(with: credential) { authResult, error in
                            if let error = error {
                                self.stopLoading()
                                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                                return
                            }
                            guard let uid = authResult?.user.uid else {return}
                            
                            APIManager.getUserData(id: uid) { (userDetails) in
                                if userDetails != nil {
                                    // User data already found on database
                                    
                                    //TODO: apply check on user status
                                    if userDetails?.isDeleted == true {
                                        self.stopLoading()
                                        self.showAlert(title: AlertConstants.Alert, message: "Your Account is locked, contact to admin")
                                    } else {
                                        self.saveUserToDefaults(userDetails!)
                                        self.stopLoading()
                                        
                                        let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
                                        let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                                        "toBottomBarID")
                                        UIApplication.shared.windows.first?.rootViewController = vc
                                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                                    }
                                } else { // User data is not found on database†
                                    let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                                    
                                    vc.uid = uid
                                    vc.email = self.email
                                    vc.name = self.name
                                    
                                    if let picture = fbDetails["picture"] as? [String:Any] ,
                                       let imgData = picture["data"] as? [String:Any] ,
                                       let imgUrl = imgData["url"] as? String {
                                        print(imgUrl)
                                        vc.profileImgUrl = "\(imgUrl)"
                                    }
                                    self.stopLoading()
                                    vc.isSocialLogin = true
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                
                            } error: { (desc) in
                                self.stopLoading()
                                self.showAlert(title: AlertConstants.Error, message: desc)
                            }
                        }
                        
                    } else {
                        self.showAlert(title: AlertConstants.Alert, message: error?.localizedDescription ?? AlertConstants.SomeThingWrong)
                        print("error occured.",error?.localizedDescription as Any)
                    }
                }
                break
            case .cancelled:
                stopLoading()
                showAlert(title: AlertConstants.Alert, message: "The user cancelled the login-flow.")
                print("user cancelled the login Flow")
                break
            case .failed(let error):
                stopLoading()
                self.showAlert(title: AlertConstants.Error, message: error.localizedDescription)
                print("Error occured \(error.localizedDescription)")
            }
        }
    }
    
    
    
    @IBAction func appleBtnAction(_ sender: Any) {
        self.startSignInWithAppleFlow()
    }
    
    @IBAction func loginWithEmailAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SignInVC_id") as? SignInVC
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension MainScreenVC: ASAuthorizationControllerDelegate {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        //      authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            self.startLoading()
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                self?.stopLoading()
                if (error != nil) {
                    print(error?.localizedDescription as Any)
                }
                // User is signed in to Firebase with Apple.
                guard let authResult = authResult else { return }
                self?.hasAccount(userId:authResult.user.uid, appleEmail: authResult.user.email ?? "", appleIDCredential: appleIDCredential)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
    
    
    private func hasAccount(userId:String, appleEmail: String, appleIDCredential: ASAuthorizationAppleIDCredential) {
        
        self.startLoading()
        APIManager.getUserData(id: userId) { (userDetails) in
            self.stopLoading()
            if userDetails != nil {
                // User data already found on database
                //TODO: apply check on user status
                if userDetails?.isDeleted == true {
                    self.stopLoading()
                    self.showAlert(title: AlertConstants.Alert, message: "Your Account is locked, contact to admin")
                } else {
                    self.saveUserToDefaults(userDetails!)
                    self.stopLoading()
                    
                    let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                    "toBottomBarID")
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            } else { // User data is not found on database†
                self.createAccountForApple(userId: userId, appleEmail: appleEmail, appleIDCredential: appleIDCredential)
            }
        } error: { (desc) in
            self.stopLoading()
            self.showAlert(title: AlertConstants.Error, message: desc)
        }
    }
    
    func createAccountForApple(userId:String, appleEmail: String, appleIDCredential: ASAuthorizationAppleIDCredential) {
        
        // let appleUser = appleIDCredential.user  // apple uid
        
        let fullName = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
        var username = fullName.removeSpecialCharacters
        username = username.removeWhitespace()
        username = username.removingAllExtraNewLines
        if username == "" {
            username = "mypress"
        }
        username = (username) + "\(Int.random(in: 1000..<9999))"
        
        let user = User(id: userId, name: fullName, email: appleEmail, fcmToken: BaseClass().getFCM(), profileUrl: "", bio: "", username: username, phone: "", gender: "", dob: "", address: "", parentID: userId, profileOn: 1, isDeleted: false, platform: "iOS", profileName: "")
        
        let param = user.asDictionary
        
        // Create User on firebase
        self.startLoading()
        Constants.refs.databaseUser.child(userId).setValue(param) { (error: Error?, ref:DatabaseReference) in
            if let error = error {
                self.stopLoading()
                print("Error Occured", error)
                super.showAlert(title: AlertConstants.Alert, message: "Error")
                
            } else {
                super.showAlert(title: AlertConstants.Success, message: AlertConstants.SignUpSuccess) {
                    
                    UserDefaults.standard.setValue(true, forKey: Constants.status)
                    
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: Constants.customer)
                    UserDefaults.standard.synchronize()
                    
                    //TODO: Successfully login and move to home controller if subscripton is done
                    let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                    "toBottomBarID")
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
        }
    }
}


