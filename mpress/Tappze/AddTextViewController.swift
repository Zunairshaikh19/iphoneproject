

import UIKit

class AddTextViewController: BaseClass, UITextViewDelegate {
    
    @IBOutlet weak var OuterView: UIView!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var textCountLbl: UILabel!
    
    @IBOutlet weak var totalCountLbl: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton! {
        didSet {
            cancelBtn.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
            cancelBtn.layer.shadowOpacity = 0.5
            cancelBtn.layer.shadowRadius = 0.0
            cancelBtn.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cancelBtn.layer.masksToBounds = false
        }
    }
    
    @IBOutlet weak var textVu: UITextView! {
        didSet {
            textVu.delegate = self
        }
    }
    
    var topText = "About Yourself"
    var bioText = ""
    var delegate:TextBackProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        topLbl.text = topText
        if bioText != "" && bioText != "Bio" {
            textVu.text = bioText
            textVu.textColor = .black
            textCountLbl.text = "\(bioText.count)"
        } else {
            textVu.text = topText
            textCountLbl.text = "0"
            textVu.textColor = .lightGray
        }
    }
    override func viewWillLayoutSubviews() {
        OuterView.roundCorners(corners: [.topLeft,.topRight], radius: 30.0)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let text = textVu.text, text != "", text != topText  else {
            showAlert(title: "Alert", message: "This field can not be empty.")
            return
        }
        delegate?.textReceived(text: textVu.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = .lightGray
            textView.text = topText
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        textCountLbl.text = "\(numberOfChars)"
        return numberOfChars < 250   // 50 Limit Value
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 251
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == topText {
            textView.text = ""
        }
        textView.textColor = .black
        
    }
    
}
