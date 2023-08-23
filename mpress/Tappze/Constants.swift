

import Foundation
import Firebase
import FirebaseDatabase
import StoreKit
import CoreLocation

var userLinks : [Links]? = []
let imgChache = NSCache<AnyObject, AnyObject>()
var userAllLinks : [Links]? = []
var userTags: [tagUid] = []
var baseUrl = "https://profile.mypress.com/"
var openProfile = false
var profileId = ""
var currentLocation: CLLocation?

//MARK: In app purchase constants
var iapProducts = [SKProduct]()
let monthlyIdentifier = "com.mypress.app.monthly"
let yearlyIdentifier = "com.mypress.app.yearly"
let lifeTimeIdentifier = "com.mypress.app.lifetime"

//var appVersion = AppVersion.free
var purchasedSubscription = Subscription.none
var purchasedCard = false

enum AppVersion: String {
    case free, monthly, yearly, lifeTime
}
enum Subscription: String {
    case none, monthly, yearly, lifeTime
}
var subscriptionPurchaseDate: String?
var subscriptionExpiryDate: String?

struct Constants {
    
    static let firebaseServerKey = "AAAAp7jAyEA:APA91bHsdaQmg1XOE9_fFxRAqnTFFOX5lRHH8n8F5weBoi06VrEfClH-BKWguJp9E7RqoEi60SJ1W6Ee5fiWEe177YvKyprulszvH-R0YtqMGaQjzNTnupaHg9UOpJFiROylSOcaEFn2"
    static let status = "userStatus"
    static let googleClientID = "720359180352-qdk0hgc0f6siiuk8cgkt7sbttgupb1na.apps.googleusercontent.com"
    static let profileUpdateNotif = Notification.Name("profileUpdate")

    static let customer = "userData"
    
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseUser = databaseRoot.child("Users")
        static let allLinks = databaseRoot.child("TestLinks")
        static let databaseContacts = databaseRoot.child("Contacts")
        static let databaseBaseUrl = databaseRoot.child("BaseUrl")
        static let databaseTag = databaseRoot.child("Tag")
        static let databaseAnalytic = databaseRoot.child("Analytic")
    }
    
}

internal struct AlertConstants {
    
    static let Error = "Error!"
    static let Alert = "Alert"
    static let DeviceType = "ios"
    static let Ok = "Ok"
    static let EmailNotValid = "Email is not valid."
    static let PhoneNotValid = "Phone number is not valid."
    static let EmailEmpty = "Email is empty."
    static let PhoneEmpty = "Phone number is empty"
    static let FirstNameEmpty = "First name is empty"
    static let LastNameEmpty = "Last name is empty"
    static let NameEmpty = "Name is empty"
    static let Empty = " is empty"
    static let PasswordsMisMatch = "Make sure your passwords match"
    static let LoginSuccess = "Login successful"
    static let SignUpSuccess = "Signup successful"
    static let emailPasswordInvalid = "Email or password is not valid"
    static let PasswordEmpty = "Password is empty"
    static let shortPassword = "Password must be atleast 6 digits"
    static let emptyFieldAlert = "This field can not be empty"
    static let Success = "Success"
    static let InternetNotReachable = "Your phone does not appear to be connected to the internet. Please connect and try again"
    static let UserNameEmpty = "Username is empty"
    static let TermsAndCondition = "Terms and conditions have not been accepted"
    static let AllFieldNotFilled = "Make sure all fields are filled"
    static let fieldCanBeEmpty = "This field can not be empty"

    static let SomeThingWrong = "Some thing went wrong"
    static let SelectFromDropDown = "Please select value from Dropdown"
    
    /*
     alerts for hints
     */
    static let whatsappMessage = "Add your phone number including your country code (e.g. +6581234567)"
    
    static let fbAlertMessage = """
    1. Open up your Facebook app and log into your Facebook account.\n
    2. From the home page, click on the menu icon at the bottom right corner (It looks like three horizontal lines.)\n
    3. Click on your profile picture to go to your profile page.\n
    4. Click on the Profile settings tab (three dots).\n
    5. Click on Copy Link to copy your full Facebook profile link.\n
    6. Paste the link into the Facebook URL field. (e.g. www.facebook.com/your_fb_id).\n
    """
    
    static let linkedInAlertMessage = """
    Linkedin:-\n
    1. Open your LinkedIn app and log into your account.\n
    2. Go to your profile page.\n
    3. Click on the three dots beside "add section".\n
    4. Select Share via...\n
    5. Select Copy.\n
    6. Paste the copied link into the LinkedIn URL field.
    """
    
    static let instaGramMessage = """
    1. Open up your Instagram app and log into your account.\n
    2. Click on your profile picture at the bottom right corner.\n
    3. Your username will be shown at the very top of your profile (above your profile picture).\n
    4. Paste your username into the Instagram URL field.\n
    """
    
    static let twitterMessage = """
    1. Open your Twitter app and log into your account.\n
    2. Click on your profile picture located at the top left corner.\n
    3. Your username will be shown under your profile picture.\n
    4. Copy and paste your username into the Twitter URL field.\n
    """
    
    static let twitchMessage = """
    If you are using the twitch app on a mobile phone:\n
    1: Go to twitch app and log into your account.
    2: Click your profile picture in the top left corner, then under profile picture.
    3: \nYour username will be shown under the profile picture.
    """
    
    static let telegramMessage = """
        1. Open your Telegram app and log into your account.\n
        2. Click on settings located at the bottom right corner.\n
        3. Your username will be shown under your contact number.\n
        4. Copy and paste your username into the Telegram URL field.\n
    """

    static let youtubeMessage = """
        1. Sign in to your YouTube Studio account.\n
        2. From the Menu, select Customisation Basic Info.\n
        3. Click into the Channel URL and copy the link.\n
        4. Paste the copied link into the YouTube URL field.\n
    """
    
    static let pintrestMessage = """
    1. Open your Pinterest app and log into your account.\n
    2. Click onto your profile picture located at the bottom right corner.\n
    3. Click into the three dots menu located at the top right corner.\n
    4. Select copy profile link.\n
    5. Paste the copied link into the Pinterest URL field.\n
    """
    
    static let snapchatMessage = """
    1. Open your Snapchat app and log into your account.\n
    2. Tap into your profile icon at the top left corner of the screen.\n
    3. Your username is shown next to your Snapchat score.\n
    4. Copy and paste the username into the Snapchat URL field.\n
    """
    
    static let tiktokMessage = """
        1. Open your TikTok app and log into your account.\n
        2. Click on profile located at the bottom right corner.\n
        3. Your username will be shown under your profile picture.\n
        4. Copy and paste your username into the TikTok URL field.\n
        """
    
    static let paypalMessage = """
         1. Go to www.paypal.com and log in.\n
         2. Under your profile, select Get Paypal.me\n
         3. Create a Paypal.me profile.\n
         4. Copy your created Paypal.me link and paste it into the Paypal URL field.\n
        """
    
    static let vimeoMessage = "1. Visit www.vimeo.com and log into your account.\n\n2. Click into settings.\n\n3. Go to your profile page and copy the Vimeo URL located at the bottom.\n\n4. Paste the copied link into the Vimeo URL field."
    
    static let redditMessage = "1. Open your Reddit app and log into your account.\n2. Click on the top left corner profile icon.\n3. Copy the username under the profile avatar (e.g. u/username).\n4. Paste username into the Reddit URL field.\n"
    
    static let paylahMessage = "1. Open up your Paylah! app and log into your account.\n2. Go to My QR.\n3. Click on Share via.\n4. Select copy and paste the copied link into your phone notes.\n5. Select the Paylah link portion, copy and paste into the Paylah! URL field."
    
    static let calendlyMessage = "1. Open up your Calendly app and log into your account.\n\n2. Copy the URL link below your name.\n\n3. Paste the copied link into the Calendly URL field."
    
    static let customLink = "Input a website link/ URL of your choice."
    
    static let contact = "Add your phone number including your country code (eg: +6581234567)"

    static let email = "Input your email address."
    
    static let text = "Add your phone number including your country code (eg: +6581234567)"
    
    static let spotify = "1. Search for your favourite Artist or Albums.\n\n2. Click on the three dots menu selection and select share.\n\n3. Select Copy Link.\n\n4. Paste the copied link into the Spotify URL Field."
    
}

enum connectBtnTitle : String {
    case Connected = "Connected"
    case Invited = "Invited"
    case Accept = "Accept"
    case Connect = "Connect"
}

internal struct APIUrl {
    
    
}
struct FirebaseConst {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chatThreads")
        static let databaseUser = databaseRoot.child("UsersList")
    }
}

enum Storyboards {
    case Main
    var id: String {
        return String(describing: self)
    }
}




///////
let requestDateFormat = "yyyy-MM-dd"
let requestTimeFormat = "HH:mm:ss"


// textField validators REGEX
//let REGEX_USER_NAME_LIMIT  = "^.{3,100}$"
let REGEX_NAME  = "[A-Za-z]{6,100}"
let REGEX_NAME_MSG = "Name charaters limit should be between 3-10."

let REGEX_USER_NAME  = "^(?=.{1,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
let REGEX_USER_NAME_MSG = "Username length should be minimum 3. Username must start and end with char or number. Special char are not allowed"

let REGEX_EMAIL  = "[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
let REGEX_EMAIL_MSG = "Enter a valid email address"

let REGEX_PASSWORD  = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{4,}$"
let REGEX_PASSWORD_MSG = "Password must be at least 8 characters, contain uppercase and lowercase letters, numbers and special characters (e.g..,%,$)"

let REGEX_CONFIRM_PASSWORD  = "[A-Za-z0-9]{6,20}"
let REGEX_CONFIRM_PASSWORD_MSG = "Password does not match"


let REGEX_PASSWORD_LIMIT  = "^.{8,64}$"
let REGEX_PASSWORD_LIMIT_MSG = "Password charaters limit should be between 8-64."

let REGEX_PHONE = "^.{8,20}$"
let REGEX_PHONE_MSG = "Phone number charaters limit should be between 8-64."


// base url for images
let imgBaseUrl = "https://.com/api"

