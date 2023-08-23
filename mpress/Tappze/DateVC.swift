
import UIKit

class DateVC: BaseClass {
    
    var delegate: getDate?
    var oldDate = ""
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelBtn: UIButton!{didSet {self.addShadowtoBtn(btn: cancelBtn)}}
    @IBOutlet weak var doneBtn: UIButton!{didSet {self.addShadowtoBtn(btn: doneBtn)}}
    @IBOutlet weak var dobSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let swich = UserDefaults.standard.bool(forKey: "switch-key")
        if swich == true {
            dobSwitch.isOn = true
        } else {
            dobSwitch.isOn = false
        }
        
        if oldDate != "" && oldDate != "Date of Birth" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,yyyy"
            let date = dateFormatter.date(from: oldDate)
            let optional = dateFormatter.string(from: Date())
            datePicker.date = date ?? dateFormatter.date(from: optional)!
        }
    }
    
    @IBAction func infoBtnPressed(_ sender: Any) {
        if dobSwitch.isOn {
            self.showAlert(title: "Alert", message: "By turning it off your DOB will not show on profile link") } else {
                self.showAlert(title: "Alert", message: "By turning it on your DOB will show on profile link")
            }
    }
    @IBAction func donePressed(_ sender: Any) {
        if dobSwitch.isOn == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd,yyyy"
            
            delegate?.getSelectedDate(formatter.string(from: datePicker.date))
            dismiss(animated: true)
        } else {
            showAlert(title: "Alert", message: "DOB update is off")
        }
        
        
        
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   
    @IBAction func dobSwitchChanged(_ sender: UISwitch) {
        if (sender.isOn == true) {
            print("on")
            UserDefaults.standard.set(true, forKey: "switch-key")
        } else {
            UserDefaults.standard.set(false, forKey: "switch-key")
            delegate?.getSelectedDate("Date of Birth")
        }
    }
    
}
