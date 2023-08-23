

import UIKit

class CellProfileList: UITableViewCell {

    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var user_img: UIImageView!
    @IBOutlet weak var selected_id_img: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    
    var editNameBtnPressed: ()->() = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editNameBtn(_ sender: Any) {
        editNameBtnPressed()
    }
    
}
