

import UIKit
import StoreKit
class InAppPurchaseVC: BaseClass {

    //Top step 1 View:
    @IBOutlet weak var buyCardVu: UIView!
    @IBOutlet weak var buySubscriptionVu: UIView!
    @IBOutlet weak var cardImgVu: UIImageView!
    
    @IBOutlet weak var cardPriceLbl: UILabel!
    @IBOutlet weak var buyCardBtn: UIButton!
    @IBOutlet weak var cardLbl: UILabel!
    //Step 2 View:
    @IBOutlet weak var segment: UISegmentedControl!
    //Package 1 view
    @IBOutlet weak var package1TitleLbl: UILabel!
    @IBOutlet weak var package1PriceLbl: UILabel!
    @IBOutlet weak var package1DescriptionLbl: UILabel! {didSet{
        package1DescriptionLbl.textAlignment = .left
    }}
    @IBOutlet weak var pkg1SelectBtn: UIButton!
    
    //Package 2 view
    @IBOutlet weak var package2TitleLbl: UILabel!
    @IBOutlet weak var package2PriceLbl: UILabel!
    @IBOutlet weak var package2DescriptionLbl: UILabel!
    @IBOutlet weak var pkg2SelectBtn: UIButton!
    
    @IBOutlet weak var buySubscriptionBtn: UIButton!
    @IBOutlet weak var restoreSubscriptionBtn: UIButton!

    @IBOutlet weak var restoreCardBtn: UIButton!

    var productID:String!
    var selectedSubScription:Int!
    let paymentQueue = SKPaymentQueue.default()
    var cardProduct: SKProduct?
    var monthlyProduct: SKProduct? = nil
    var yearlyProduct: SKProduct? = nil
    var lifeTimeProduct: SKProduct? = nil

    var selectedProduct: SKProduct? = nil
    var previousVC :String?
    var enteredInQueu = false

    let backendCheckoutUrl = URL(string: "https://swanky-cypress-persimmon.glitch.me/create-payment-intent")!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stripeInitalSetup()
        initialViewSetup()
        handleInAppFetchedProducts()
        fetchAvailableProducts()
        // In App Purchase related code
        SKPaymentQueue.default().add(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectPackageOfSelectedIndex()
    }
    
    //MARK: UI Work
    func initialViewSetup() {
        
        let user = readUserData()
        cardLbl.text = user?.name ?? "MR. Sahil Anand"
        segment.selectedSegmentIndex = 2
        showLifeTimeProduct(tempProduct: nil)
        self.cardPriceLbl.text = "Card Price: $55"
        //restoreCardBtn.isEnabled = false
    }
    
    
    //MARK: Segment Actions
    @IBAction func segmentChanged(_ sender: Any) {
        pkg1SelectBtn.setImage(nil, for: .normal)
        pkg2SelectBtn.setImage(nil, for: .normal)
       // selectedProduct = nil
        self.selectPackageOfSelectedIndex()
    }
    func selectPackageOfSelectedIndex() {
        switch segment.selectedSegmentIndex
        {
        case 0:
            selectedProduct = monthlyProduct
            showMonthlyProduct(tempProduct: monthlyProduct)
        case 1:
            selectedProduct = yearlyProduct
            showYearlyProduct(tempProduct: yearlyProduct)
        case 2:
            selectedProduct = lifeTimeProduct
            showLifeTimeProduct(tempProduct: lifeTimeProduct)

        default:
            break;
        }
    }
    //MARK: Show Packages
    func showMonthlyProduct(tempProduct: SKProduct?) {
        self.package1TitleLbl.text = tempProduct?.localizedTitle ?? "Monthly Subscription"
        if tempProduct != nil {
            self.package1PriceLbl.text = "\(tempProduct?.priceLocale.currencySymbol ?? "$")\(tempProduct?.price ?? 4.99)/month"

        } else {
            self.package1PriceLbl.text = "$4.99/month"
        }
        self.package1DescriptionLbl.text = """
This subscription will give you access of limited features.
1: You can make your profile with limited features.
2: You can add upto 6 social links.
"""
    }
    
    func showYearlyProduct(tempProduct: SKProduct?) {
        self.package1TitleLbl.text = tempProduct?.localizedTitle ?? "Yearly Subscription"
        if tempProduct != nil {
            self.package1PriceLbl.text = "\(tempProduct?.priceLocale.currencySymbol ?? "$")\(tempProduct?.price ?? 44.99)/year"

        } else {
            self.package1PriceLbl.text = "$44.99/year"
        }
        self.package1DescriptionLbl.text = """
        This subscription will give you access of limited features.
        1: You can create profile including profile picture, personal information.
        2: You can add unlimited social icons to make the profile look better.
        """
    }
    func showLifeTimeProduct(tempProduct: SKProduct?) {
        self.package1TitleLbl.text = tempProduct?.localizedTitle ?? "Life Time Subscription"
        if tempProduct != nil {
            self.package1PriceLbl.text = "\(tempProduct?.priceLocale.currencySymbol ?? "$")\(tempProduct?.price ?? 99.99)"

        } else {
            self.package1PriceLbl.text = "$99.99"
        }
        self.package1DescriptionLbl.text = """
        This subscription will give you access of all features.
        1: You can create profile including profile picture.
        2: You can add unlimited icons.
        3: You can do customization of custom icons.
        4: Can use Lead Form to capture leads.
        5: You can see analytics.
        6: You can add multiple profiles and switch easily from one profile to another.
        """
    }
    

    
    //MARK: Button Actions
    @IBAction func restoreSubscriptionBtn(_ sender: UIButton) {
        
        let user = readUserData()
        if (user?.subscription ?? "none") != "none" {
            SKPaymentQueue.default().add(self)
            if (SKPaymentQueue.canMakePayments()) {
              SKPaymentQueue.default().restoreCompletedTransactions()
            }
        } else {
            showAlert(title: "Alert", message: "You have not purchased a package or package is expired that can not be restored")
        }
    }
    
    @IBAction func restoreCardBtn(_ sender: UIButton) {
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
          SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        if previousVC == "dashboard" {
            let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier:
                                                            "toBottomBarID")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            let yesNoAlert = UIAlertController(title: AlertConstants.Alert, message: "Do you want to go back to login screen?", preferredStyle: UIAlertController.Style.alert)
            yesNoAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier:
                                                                "SignInVC_id")
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
              }))

            yesNoAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
              }))

            present(yesNoAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func pkg1SelectBtn(_ sender: Any) {
        pkg1SelectBtn.setImage(UIImage(named: "ic_checked"), for: .normal)
        pkg2SelectBtn.setImage(nil, for: .normal)
        if segment.selectedSegmentIndex == 0 {
            selectedProduct = monthlyProduct
        }
        else if segment.selectedSegmentIndex == 1 {
            selectedProduct = monthlyProduct
        }
    }
    
    @IBAction func pkg2SelectBtn(_ sender: UIButton) {
        pkg1SelectBtn.setImage(nil, for: .normal)
        pkg2SelectBtn.setImage(UIImage(named: "ic_checked"), for: .normal)

        if segment.selectedSegmentIndex == 0 {
            selectedProduct = yearlyProduct
        }
        else if segment.selectedSegmentIndex == 1 {
            selectedProduct = lifeTimeProduct
        }
    }

    @IBAction func buyCardBtn(_ sender: UIButton) {
        
        //buyCardWithStripe()
    }
    @IBAction func privacyPolicyPressed(_ sender: Any) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        self.present(vc, animated: true, completion: nil)

    }
    
    func displayAlert(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func buySubscriptionBtn(_ sender: UIButton) {
        if let selectedProduct = selectedProduct  {
            self.buyProduct(selectedProduct)
            
        } else {
            self.selectPackageOfSelectedIndex()
            showAlert(title: AlertConstants.Alert, message: "Please try again a few moments later.")
        }
    }

    //MARK: shadowView round
    func shadowView(viewName: UIView)
    {
        viewName.layer.cornerRadius = 15
        viewName.layer.shadowColor = UIColor.darkGray.cgColor
        viewName.layer.shadowOpacity = 0.8
        viewName.layer.shadowOffset = CGSize.zero
        viewName.layer.shadowRadius = 8
        viewName.clipsToBounds = false
    }
    
}


//MARK: Extension for IN-APP-Purchase Work
extension InAppPurchaseVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    //MARK: IN-APP-Purchase fetch products
   
    func fetchAvailableProducts(){
        // Put here your IAP Products ID's
        //let productIdentifiers = NSSet(objects: autoRenewal)
        let productIdentifiers = NSSet(array: [monthlyIdentifier, yearlyIdentifier, lifeTimeIdentifier])
        
        var productsRequest = SKProductsRequest()
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
        
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        DispatchQueue.main.async { [self] in
            if (response.products.count > 0) {
                iapProducts = response.products
                handleInAppFetchedProducts()
            } else {
            }
        }
    }
    
    func handleInAppFetchedProducts() {
        for tempProduct in iapProducts {
            if tempProduct.productIdentifier == monthlyIdentifier {
                monthlyProduct = tempProduct
                if segment.selectedSegmentIndex == 0 {
                    showMonthlyProduct(tempProduct: tempProduct)
                }
            }
            if tempProduct.productIdentifier == yearlyIdentifier {
                yearlyProduct = tempProduct
                if segment.selectedSegmentIndex == 1 {
                    showYearlyProduct(tempProduct: tempProduct)
                }
            }
            if tempProduct.productIdentifier == lifeTimeIdentifier {
                lifeTimeProduct = tempProduct
                if segment.selectedSegmentIndex == 2 {
                    showLifeTimeProduct(tempProduct: tempProduct)
                }
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(request)
        print(error)
    }
    
    //MARK: IN-APP-Purchase Buy products

    func buyProduct(_ product: SKProduct) {
        // Add the StoreKit Payment Queue for ServerSide
        SKPaymentQueue.default().add(self)

        if SKPaymentQueue.canMakePayments() {
            print("Sending the Payment Request to Apple")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            print("cant purchase")
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions {
        
            if let trans = transaction as? SKPaymentTransaction {
            
                switch trans.transactionState {
                
                    case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseSuccess(transaction: trans, productIdentifier:trans.payment.productIdentifier)
                    //selectedProduct = nil
                    self.dismiss(animated: true, completion: nil)
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print("Fail")
                    break
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseSuccess(transaction: trans, productIdentifier:  trans.original?.payment.productIdentifier)
                        //selectedProduct = nil
                    self.dismiss(animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        }
    }

    
    func purchaseSuccess(transaction: SKPaymentTransaction, productIdentifier: String?) {
        
        self.updateSubscriptionStatus(productIdentifier: productIdentifier)
        self.receiptValidation()
    }
    
    func updateSubscriptionStatus(productIdentifier: String?) {
        
        if productIdentifier == monthlyIdentifier {
            purchasedSubscription = .monthly
        }
        else if productIdentifier == yearlyIdentifier {
            purchasedSubscription = .yearly
        }
        else if productIdentifier == lifeTimeIdentifier {
            purchasedSubscription = .lifeTime
        }
        
        var loggedUser = self.readUserData()
        loggedUser?.subscription = purchasedSubscription.rawValue
        self.saveUserToDefaults(loggedUser!)
        
        APIManager.updateUserSubscription(subscriptionType: purchasedSubscription) { status in
            print("\(status)")
            let storyBoard = UIStoryboard(name: "BottomBar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier:
                                                            "toBottomBarID")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
