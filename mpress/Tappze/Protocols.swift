

import Foundation

protocol TextBackProtocol {
    func textReceived(text: String)
}
protocol LinkAdded {
    func linkReceived(text: String,platform: String,imageUrl: String?, isShared:Bool)
}
protocol LinkDeleted {
    func deleteLink(platform: String)
}
protocol getDate {
    func getSelectedDate(_ date: String)
}
protocol verifyTag {
    func tagVerification(_ status: Bool)
}

