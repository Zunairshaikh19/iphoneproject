

import UIKit

class ProfileStatusAlertVC: BaseViewController {
    
    @IBOutlet weak var main_bgView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var tag_on_Off_lbl: UILabel!
    var tag_on_Off_status : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        main_bgView.clipsToBounds = true
        main_bgView.layer.cornerRadius = 22
        
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 8
        
        // tag_on_Off_lbl status
        if (tag_on_Off_status == true){
            
            self.tag_on_Off_lbl.text = "Your profile is active now and will be visible to others."
        }else{
            self.tag_on_Off_lbl.text = "Your profile is Inactive now and will not be visible to others."
        }
        
    }
    
    @IBAction func okBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
