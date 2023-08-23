


import UIKit
import NFCReaderWriter

class NfcVC: BaseClass {
    
    @IBOutlet weak var activateTagBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var buyTagBtn: UIButton!
    
    let readerWriter = NFCReaderWriter.sharedInstance()
    var userId = ""
    var idInPayload = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        activateTagBtn.clipsToBounds = true
        activateTagBtn.layer.cornerRadius = 8
        
        buyTagBtn.layer.cornerRadius = 8
        buyTagBtn.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        // username get from userDefaults
        let user = readUserData()
        self.usernameLbl.text = user?.username ?? ""
        
        userId = getUserId()
        
    }
    
    @IBAction func buyTappzeCardTapped(_ sender: Any) {
        let validUrlString = "https://MyPress.com/collections/all"
        guard let url = URL(string: validUrlString) else {return}
        UIApplication.shared.open(url)
    }
    
    //MARK: Button Actions
    @IBAction func activateBtnTapped(_ sender: Any) {
        readerWriter.newWriterSession(with: self, isLegacy: true, invalidateAfterFirstRead: true, alertMessage: "Ready to scan - hold the MyPress card and close to your smartphone to set up your profile")
        readerWriter.begin()
        self.readerWriter.detectedMessage = "Write data successfully"
    }
    
    
    
    // MARK: - Utilities
    func contentsForMessages(_ messages: [NFCNDEFMessage]) -> String {
        var recordInfos = ""
        
        if let record = messages.first?.records.first {
            if let string = String(data: record.payload, encoding: .ascii) {
                recordInfos = "\(string)"
            }
        }
        return recordInfos
    }
    
    func getTagInfos(_ tag: __NFCTag) -> [String: Any] {
        var infos: [String: Any] = [:]
        
        switch tag.type {
        case .miFare:
            if #available(iOS 13.0, *) {
                if let miFareTag = tag.asNFCMiFareTag() {
                    switch miFareTag.mifareFamily {
                    case .desfire:
                        infos["TagType"] = "MiFare DESFire"
                    case .ultralight:
                        infos["TagType"] = "MiFare Ultralight"
                    case .plus:
                        infos["TagType"] = "MiFare Plus"
                    case .unknown:
                        infos["TagType"] = "MiFare compatible ISO14443 Type A"
                    @unknown default:
                        infos["TagType"] = "MiFare unknown"
                    }
                    if let bytes = miFareTag.historicalBytes {
                        infos["HistoricalBytes"] = bytes.hexadecimal
                    }
                    infos["Identifier"] = miFareTag.identifier.hexadecimal
                }
            } else {
                // Fallback on earlier versions
            }
        case .iso7816Compatible:
            if #available(iOS 13.0, *) {
                if let compatibleTag = tag.asNFCISO7816Tag() {
                    infos["TagType"] = "ISO7816"
                    infos["InitialSelectedAID"] = compatibleTag.initialSelectedAID
                    infos["Identifier"] = compatibleTag.identifier.hexadecimal
                    if let bytes = compatibleTag.historicalBytes {
                        infos["HistoricalBytes"] = bytes.hexadecimal
                    }
                    if let data = compatibleTag.applicationData {
                        infos["ApplicationData"] = data.hexadecimal
                    }
                    infos["OroprietaryApplicationDataCoding"] = compatibleTag.proprietaryApplicationDataCoding
                }
            } else {
                // Fallback on earlier versions
            }
        case .ISO15693:
            if #available(iOS 13.0, *) {
                if let iso15693Tag = tag.asNFCISO15693Tag() {
                    infos["TagType"] = "ISO15693"
                    infos["Identifier"] = iso15693Tag.identifier
                    infos["ICSerialNumber"] = iso15693Tag.icSerialNumber.hexadecimal
                    infos["ICManufacturerCode"] = iso15693Tag.icManufacturerCode
                }
            } else {
                // Fallback on earlier versions
            }
            
        case .feliCa:
            if #available(iOS 13.0, *) {
                if let feliCaTag = tag.asNFCFeliCaTag() {
                    infos["TagType"] = "FeliCa"
                    infos["Identifier"] = feliCaTag.currentIDm
                    infos["SystemCode"] = feliCaTag.currentSystemCode.hexadecimal
                }
            } else {
                // Fallback on earlier versions
            }
        default:
            break
        }
        return infos
    }
    
}

@available(iOS 11.0, *)
extension NfcVC: NFCReaderDelegate {
    func readerDidBecomeActive(_ session: NFCReader) {
        print("Reader did become")
    }
    
    func reader(_ session: NFCReader, didInvalidateWithError error: Error) {
        print("ERROR:\(error)")
        readerWriter.end()
    }
    
    /// -----------------------------
    // MARK: 2. NFC Writer(iOS 13):
    /// -----------------------------
    @available(iOS 13.0, *)
    func reader(_ session: NFCReader, didDetect tags: [NFCNDEFTag]) {
        print("did detect tags")
        
        let uriPayloadFromURL = NFCNDEFPayload.wellKnownTypeURIPayload(
            url: URL(string: baseUrl+getUserId())!
        )!
                
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
    
    /// --------------------------------
    // MARK: 3. NFC Tag Reader(iOS 13)
    /// --------------------------------
    /*
     The important method for reading data from an NFC tag is readerSession(_:didDetectNDEFs:). The reader session calls this method once a tag with an NDEF message is found.
     */
    func reader(_ session: NFCReader, didDetect tag: __NFCTag, didDetectNDEF message: NFCNDEFMessage) {
        _ = readerWriter.tagIdentifier(with: tag)
        let payload = contentsForMessages([message])
        let tagInfos = getTagInfos(tag)
        var tagInfosDetail = ""
        tagInfos.forEach { (item) in
            tagInfosDetail = tagInfosDetail + "\(item.key): \(item.value)\n"
        }
        
        DispatchQueue.main.async {
            print("Tag Data:",payload)
            guard !payload.isEmpty else {
                self.showAlert(title: AlertConstants.Alert, message: "No data found in Pod.")
                return
            }
            
            self.idInPayload = payload
            // self.performSegue(withIdentifier: "viewContact", sender: self)
        }
        self.readerWriter.alertMessage = "NFC Tag Info detected"
        self.readerWriter.end()
    }

}

extension Data {
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
        .joined()
    }
}

