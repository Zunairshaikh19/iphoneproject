

import UIKit
import FirebaseStorage
import NFCReaderWriter

class ShareVC: BaseClass, NFCReaderDelegate {
    
    
    
    @IBOutlet weak var copyBtn: UIButton!
    
    @IBOutlet weak var shareLinkImage: UIImageView!
    //    @IBOutlet weak var profileImg: UIImageView! {
//        didSet {
//            profileImg.isHidden = true
//            profileImg.layer.cornerRadius = profileImg.bounds.height/2
//        }
//    }
    
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    @IBOutlet weak var shareBtn:UIButton!{
        didSet {
            shareBtn.isHidden = false
        }
    }
    @IBOutlet weak var buyMPressBtn: UIButton!
    @IBOutlet weak var activatedCard: UIButton!
    @IBOutlet var usernameLbl: UILabel!
    
    let readerWriter = NFCReaderWriter.sharedInstance()
    var userName = ""
    var userId  = ""
    let storage = Storage.storage()
    var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameLbl.text = self.getUsername()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedMethod(_:)))
        shareLinkImage.isUserInteractionEnabled = true
        shareLinkImage.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedQrMethod(_:)))
        qrImage.isUserInteractionEnabled = true
        qrImage.addGestureRecognizer(tapGesture)
        
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        shareBtn.clipsToBounds = true
        copyBtn.isHidden = true
        
        shareBtn.layer.cornerRadius = 10
        buyMPressBtn.layer.cornerRadius = 10
        activatedCard.layer.cornerRadius = 10
        getbaseUrl()
    }
    
    @objc func tappedMethod(_ sender: AnyObject) {
        let shareText = URL(string: self.link)
        let vc = UIActivityViewController(activityItems: [shareText!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @objc func tappedQrMethod(_ sender: AnyObject) {
        if let url = URL(string: self.link) {
            UIApplication.shared.open(url)
        }
    }
    
//   MARK: Button Actions
    @IBAction func buyMPressAction(_ sender: Any) {
        if let url = URL(string: "https://mpressnetwork.com/shop") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        self.openUrlWithString(urlString: self.link)
        if let url = URL(string: self.link) {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func copyCodeButtonPressed(_ sender: UIButton) {
        self.showAlert(title: AlertConstants.Alert, message: "Link is copied!"){
            UIPasteboard.general.string = self.link
        }
    }
    
    @IBAction func activateMpressTagBtnPress(_ sender: Any) {writeTag()}
    
    func writeTag(){
        
        guard APIManager.isInternetAvailable() else {
            showAlert(title: AlertConstants.InternetNotReachable, message: "")
            return
        }
        
        readerWriter.newWriterSession(with: self, isLegacy: true, invalidateAfterFirstRead: true, alertMessage: "Ready to scan - hold the Mpress tag close to your smartphone to set up your tag")
        readerWriter.begin()
        self.readerWriter.detectedMessage = "Write data successfully"
    }
    
    func getbaseUrl() {
        
        self.startLoading()
        
        APIManager.getBaseUrl(){ url in
            if url != "" {
                self.stopLoading()
                
                baseUrl = url!
                self.userId = self.getUserId()
                self.link = baseUrl + self.getUsername()
                self.linkLbl.text = self.link
                self.qrImage.image = self.generateQRCode(from: self.link)
                self.copyBtn.isHidden = false
                self.shareBtn.isHidden = false
//                self.profileImg.isHidden = false
                
            }
        } err: { error in
            print(error)
        }
        
    }
    
}

extension ShareVC {
    
    func reader(_ session: NFCReader, didInvalidateWithError error: Error) {
        readerWriter.end()
    }
    
    func reader(_ session: NFCReader, didDetect tags: [NFCNDEFTag]) {
        print("did detect tags")

        let uriPayloadFromURL = NFCNDEFPayload.wellKnownTypeURIPayload(
                url: URL(string: baseUrl+self.getUsername())!)!
        
        let message = NFCNDEFMessage(records: [uriPayloadFromURL])

        readerWriter.write(message, to: tags.first!) { (error) in
            if let err = error {
                print("ERR:\(err)")
            } else {
                print("write success")
            }
            self.readerWriter.end()
        }
    }
}
