

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FirebaseCore
// for Firebase PushNotification
import Firebase
import FirebaseMessaging
import GoogleSignIn
import FirebaseAuth
import StoreKit
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Firebase PushNotification
    let gcmMessageIDKey = "gcm.message_id"
    var fcmToken_str: String!
    
    // InAppPurchase code
    let productID = "com.mypress.avicena"
    var purchaseStr = ""
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.fetchAvailableInAppProducts()
        // IQKeyboardManagerSwift
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        // Firebase PushNotification called
        self.register_PushNotification(application: application)
        
        let status = UserDefaults.standard.bool(forKey: Constants.status)
        print(status)
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        self.setInitialViewController()
        
        // func calling
        //inAppPurchase_func()
        GMSServices.provideAPIKey("AIzaSyCz-PavaolXbcRI31WD6jkJN4VuRcVgT3c")
        GMSPlacesClient.provideAPIKey("AIzaSyCz-PavaolXbcRI31WD6jkJN4VuRcVgT3c")
        return true
    }
    
    func setInitialViewController() {
        let status = UserDefaults.standard.bool(forKey: Constants.status)
        print(status)
        
        if (status == true) {
            // open BottomBar tabs
            let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier:
                                                            "toBottomBarID")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier:
                                                            "toMain")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            //fatalError("Crash was triggered")
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MyPress")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////
// below code for Firebase PushNotofication  //
////////////////////////////////////////////////////////////////////////////////////
// extension for Firebase Push Notification
extension AppDelegate
{
    // register_PushNotification
    func register_PushNotification(application: UIApplication)
    {
        // Firebase remote
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Firebase remote
        Messaging.messaging().delegate = self
        //Messaging.messaging().isAutoInitEnabled = true
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
            }
        }
        
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
    }
    
    
    ////////////////////////////////////////////////////////
    // Firebase remote funcions  //
    ///////////////////////////////////////////////////////
    // didReceiveRemoteNotification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        /*if application.applicationState == .background {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
        completionHandler(UIBackgroundFetchResult.newData)*/
        
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    // didRegisterForRemoteNotificationsWithDeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

// Firebase remote UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound, .badge]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        _ = response.notification.request.content.userInfo
        
        // Print full message (message ID)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        
        completionHandler()
        
    }
    
}

//MARK: In-App purchase work
extension AppDelegate: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if (response.products.count > 0) {
                iapProducts = response.products
            }
        }
    }
    
    func fetchAvailableInAppProducts()
    {
        // Put here your IAP Products ID's
        //let productIdentifiers = NSSet(objects: autoRenewal)
        let productIdentifiers = NSSet(array: [monthlyIdentifier, yearlyIdentifier, lifeTimeIdentifier])

        var productsRequest = SKProductsRequest()
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        let googleSignIn =  GIDSignIn.sharedInstance.handle(url)
        
        
        if (googleSignIn) {
            return true
        }
        
        return false
    }


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool  {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if userActivity.webpageURL != nil {
                // This was not a Stripe url – handle the URL normally as you would
            }
        }
        return false
    }
}

// Firebase remote MessagingDelegate
extension AppDelegate: MessagingDelegate
{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        print("Firebase FCM Token: \(String(describing: fcmToken!))")
        fcmToken_str = fcmToken!
        
        BaseClass().saveFCM(fcmToken_str)
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}


/*
// InAppPurchase code
extension AppDelegate: SKPaymentTransactionObserver
{
    func inAppPurchase_func()
    {
        // InAppPurchase code
        SKPaymentQueue.default().add(self)
        purchaseStr = "Purchase not completed yet"
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User unable to make payments")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                //if item has been purchased
                print("Transaction Successful")
                purchaseStr = "Purchase Completed!"
            } else if transaction.transactionState == .failed {
                print("Transaction Failed")
                purchaseStr = "Purchase Failed"
            } else if transaction.transactionState == .restored {
                print("restored")
                purchaseStr = "Purchase Restored!"
            }
        }
    }
    
}*/
