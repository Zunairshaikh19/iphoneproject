

import Foundation

struct User: Codable {
    
    var id: String?
    var name: String?
    var email: String?
    var fcmToken:String?
    var phone: String?
    var gender: String?
    var username: String?
    var profileUrl: String?
    var coverUrl: String?
    var bio: String?
    var dob: String?
    var address: String?
    var parentID: String?
    var profileOn: Int?
    var links : [Links]?
    var isDeleted: Bool?
    var platform: String?
    var company: String?
    var isCardPurchased: Bool?
    var subscription: String?
    var subscriptionPurchaseDate: String?
    var subscriptionExpiryDate: String?
    var leadMode: Bool?
    var profileName: String?
    var infoShareable: InfoShareable?
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    private init() {}
    static let shared = User()
    
    init(id: String? = nil,
         name: String? = nil,
         email: String? = nil,
         fcmToken: String? = nil,
         profileUrl: String? = nil,
         coverUrl: String? = nil,
         bio: String? = nil,
         username: String? = nil,
         phone: String? = nil,
         gender: String? = nil,
         dob: String? = nil,
         address: String? = nil,
         parentID: String? = nil,
         profileOn: Int? = nil,
         isDeleted: Bool? = nil,
         platform: String? = nil,
         company: String? = nil,
         isCardPurchased: Bool? = nil,
         subscription: String? = nil,
         subscriptionExpiryDate: String? = nil,
         subscriptionPurchaseDate: String? = nil,
         leadMode: Bool? = nil,
         profileName: String? = nil,
         infoShareable: InfoShareable? = nil
    ) {
        
        self.id = id
        self.email = email
        self.name = name
        self.fcmToken = fcmToken
        self.username = username
        self.profileUrl = profileUrl
        self.coverUrl = coverUrl
        self.phone = phone
        self.gender = gender
        self.bio = bio
        self.dob = dob
        self.address = address
        self.parentID = parentID
        self.profileOn = profileOn
        self.profileOn = profileOn
        self.isDeleted = isDeleted
        self.platform = platform
        self.company = company
        self.isCardPurchased = isCardPurchased
        self.subscription = subscription
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.subscriptionPurchaseDate = subscriptionPurchaseDate
        self.leadMode = leadMode
        self.profileName = profileName
        self.infoShareable = infoShareable
    }
    
    func getUserId() -> String {
        return self.id ?? ""
    }
}

struct AllLinks : Codable {
    var allSocialLinks : [Links]?
    enum CodingKeys: String, CodingKey {
        case allSocialLinks = "allSocialLinks"
    }
}
struct Links : Codable {
    var image : String?
    var isShared : Bool?
    var name : String?
    var value : String?
    var linkID: Int?
    
    enum CodingKeys: String, CodingKey {
        case linkID = "linkID"
        case name = "name"
        case value = "value"
        case image = "image"
        case isShared = "isShared"
    }
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }

    init (
        linkID: Int? = nil,
        name : String? = nil,
        value : String? = nil,
        image : String? = nil,
        isShared : Bool? = nil
    ) {
        self.linkID = linkID
        self.name = name
        self.value = value
        self.image = image
        self.isShared = isShared
     }
}


struct Tag : Codable {
    var id : String?
    var isDeleted : Bool?
    var status : Bool?
    var tagId : String?
    
    enum CodingKeys: String, CodingKey {
    case id = "id"
    case isDeleted = "isDeleted"
    case status = "status"
    case tagId = "tagId"
}
    init(
        id: String? = nil,
        isDeleted: Bool? = false,
        status: Bool? = nil,
        tagId: String? = nil
    )
    {
        self.id = id
        self.isDeleted = isDeleted
        self.status = status
        self.tagId = tagId
    }
}
    



struct tagUid: Codable {
    var id: String?
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }

}



// Analytic
struct Analytic : Codable {
    let linksEngPastWk : Int?
    let userId : String?
    let tContactsMePastWk : Int?
    let tContactsMeCrntWk : Int?
    let profilePicture : String?
    let id : String?
    let startingDate : Int?
    let totalClicks : Int?
    let linksEngCrntWk : Int?
    let links : [Link]?
    
    enum CodingKeys: String, CodingKey {
        
        case linksEngPastWk = "linksEngPastWk"
        case userId = "userid"
        case tContactsMePastWk = "tContactsMePastWk"
        case tContactsMeCrntWk = "tContactsMeCrntWk"
        case profilePicture = "profilePicture"
        case id = "id"
        case startingDate = "startingDate"
        case totalClicks = "totalClicks"
        case linksEngCrntWk = "linksEngCrntWk"
        case links = "links"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        linksEngPastWk = try values.decodeIfPresent(Int.self, forKey: .linksEngPastWk)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        tContactsMePastWk = try values.decodeIfPresent(Int.self, forKey: .tContactsMePastWk)
        tContactsMeCrntWk = try values.decodeIfPresent(Int.self, forKey: .tContactsMeCrntWk)
        profilePicture = try values.decodeIfPresent(String.self, forKey: .profilePicture)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        startingDate = try values.decodeIfPresent(Int.self, forKey: .startingDate)
        totalClicks = try values.decodeIfPresent(Int.self, forKey: .totalClicks)
        linksEngCrntWk = try values.decodeIfPresent(Int.self, forKey: .linksEngCrntWk)
        links = try values.decodeIfPresent([Link].self, forKey: .links)
    }
    
}

struct Link : Codable {
    let clicks : Int?
    let name : String?
    let updated_date : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case clicks = "clicks"
        case name = "name"
        case updated_date = "updated_date"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clicks = try values.decodeIfPresent(Int.self, forKey: .clicks)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        updated_date = try values.decodeIfPresent(Int.self, forKey: .updated_date)
    }
    
}

struct InfoShareable:Codable {
    let nameShared, emailShared, phoneShared, dobShared: Bool?
    let addressShared, bioShared, profileShared: Bool?
    let companyShared, allShared: Bool?
    enum CodingKeys: String, CodingKey {
        case nameShared = "nameShared"
        case emailShared = "emailShared"
        case phoneShared = "phoneShared"
        case addressShared = "addressShared"
        case dobShared = "dobShared"
        case bioShared = "bioShared"
        case profileShared = "profileShared"
        case companyShared = "companyShared"
        case allShared = "allShared"
    }

    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    init (
        nameShared : Bool?,
        emailShared : Bool?,
        phoneShared : Bool?,
        addressShared : Bool?,
        dobShared : Bool?,
        bioShared : Bool?,
        profileShared : Bool?,
        companyShared: Bool?,
        allShared : Bool?
    ) {
        self.nameShared = nameShared
        self.emailShared = emailShared
        self.phoneShared = phoneShared
        self.addressShared = addressShared
        self.dobShared = dobShared
        self.bioShared = bioShared
        self.profileShared = profileShared
        self.companyShared = companyShared
        self.allShared = allShared
    }
}
